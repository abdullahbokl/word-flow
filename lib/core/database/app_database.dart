import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:word_flow/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Words, WordSyncQueue, AppSettings, SyncDeadLetters])
class WordFlowDatabase extends _$WordFlowDatabase {
  WordFlowDatabase(String encryptionKey)
    : super(_openConnection(encryptionKey));

  // Test constructor: allow passing a custom QueryExecutor (e.g. in-memory DB)
  WordFlowDatabase.test(super.executor);

  static final Map<int, Future<void> Function(WordFlowDatabase)>
  _migrationSteps = {
    2: _migrate1To2,
    3: _migrate2To3,
    4: _migrate3To4,
    5: _migrate4To5,
    6: _migrate5To6,
    7: _migrate6To7,
    8: _migrate7To8,
    9: _migrate8To9,
    10: _migrate9To10,
  };

  static Future<void> _createAllIndices(DatabaseConnectionUser db) async {
    await db.customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_words_user_word ON words(user_id, word_text)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_words_known_partial ON words (user_id, is_known) WHERE is_known = 1',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_words_last_updated ON words (last_updated)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_words_known ON words(user_id, is_known)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_words_updated ON words(user_id, last_updated)',
    );
    await db.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_created ON word_sync_queue(created_at)',
    );
  }

  // Keep this assertion in sync with _migrationSteps to prevent shipping
  // schemaVersion bumps without a corresponding upgrade path.
  @override
  int get schemaVersion {
    const expectedVersion = 10;
    assert(() {
      final maxStep = _migrationSteps.keys.reduce((a, b) => a > b ? a : b);
      if (maxStep != expectedVersion) {
        throw AssertionError(
          'Developer mistake: schemaVersion is $expectedVersion but max migration step is $maxStep. Please add a migration step.',
        );
      }
      return true;
    }());
    return expectedVersion;
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createAllIndices(m.database);
    },
    onUpgrade: (m, from, to) async {
      await transaction(() async {
        for (var target = from + 1; target <= to; target++) {
          final step = _migrationSteps[target];
          if (step != null) {
            await step(this);
          } else {
            throw Exception('Unhandled upgrade step: $target');
          }
        }
      });
      assert(() {
        if (to != 10) {
          throw AssertionError(
            'Missing migration steps or wrong target schema version',
          );
        }
        return true;
      }());
    },
  );

  Stream<List<WordRow>> watchWords({String? userId}) {
    final query = select(words)
      ..where(
        (t) => userId == null ? t.userId.isNull() : t.userId.equals(userId),
      );
    return query.watch();
  }

  Future<List<String>> getKnownWordTexts({String? userId}) async {
    final query = selectOnly(words)
      ..addColumns([words.wordText])
      ..where(words.isKnown.equals(true))
      ..where(
        userId == null ? words.userId.isNull() : words.userId.equals(userId),
      );
    final rows = await query.get();
    return rows.map((r) => r.read(words.wordText)!).toList(growable: false);
  }

  Future<WordRow?> getWordById(String id) async {
    final query = select(words)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<List<WordRow>> getWordsByTexts(
    List<String> texts, {
    String? userId,
  }) async {
    final query = select(words)
      ..where((t) {
        final textIn = t.wordText.isIn(texts);
        final userMatch = userId == null
            ? t.userId.isNull()
            : t.userId.equals(userId);
        return textIn & userMatch;
      });
    return query.get();
  }

  Future<WordRow?> getWordByText(String text, {String? userId}) async {
    final query = select(words)
      ..where((t) {
        final textMatch = t.wordText.equals(text);
        final userMatch = userId == null
            ? t.userId.isNull()
            : t.userId.equals(userId);
        return textMatch & userMatch;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.lastUpdated)])
      ..limit(1);
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> upsertWords(List<WordsCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(words, rows);
    });
  }

  Future<void> upsertWordsInTransaction(List<WordsCompanion> rows) async {
    // One transaction per pull page ensures all-or-nothing local apply.
    await transaction(() async {
      await upsertWords(rows);
    });
  }

  Future<void> upsertWord(WordsCompanion row) async {
    await into(words).insertOnConflictUpdate(row);
  }

  Future<void> deleteWordById(String id) async {
    await (delete(words)..where((t) => t.id.equals(id))).go();
  }

  Future<int> adoptGuestWords(String userId) async {
    return transaction(() async {
      // 1. Get all guest words (userId == null)
      final guestWords = await (select(
        words,
      )..where((t) => t.userId.isNull())).get();

      if (guestWords.isEmpty) return 0;

      // 2. Get existing user words as a map [wordText -> WordRow]
      final existingUserWordsQuery = select(words)
        ..where((t) => t.userId.equals(userId));
      final existingUserWords = await existingUserWordsQuery.get();
      final existingMap = {
        for (final word in existingUserWords) word.wordText: word,
      };

      int adoptedCount = 0;
      final now = DateTime.now().toUtc();
      final Set<String> changedWordIds = {};

      // 3. Merge Strategy:
      // - If user DOES NOT have the word: reassign guest word to user (keeps local UUID).
      // - If user DOES have the word: merge guest stats (highest count, union isKnown)
      //   into the existing user word and delete the guest duplicate.
      // - To save bandwidth, only the IDs in changedWordIds are enqueued for sync.
      for (final guest in guestWords) {
        final existing = existingMap[guest.wordText];

        if (existing != null) {
          // CONFLICT: User already has this word from cloud. Merge into user row.
          await (update(words)..where((t) => t.id.equals(existing.id))).write(
            WordsCompanion(
              totalCount: Value(
                existing.totalCount > guest.totalCount
                    ? existing.totalCount
                    : guest.totalCount,
              ),
              isKnown: Value(existing.isKnown || guest.isKnown),
              lastUpdated: Value(now),
            ),
          );
          changedWordIds.add(existing.id);

          // Delete the now-redundant guest duplicate
          await (delete(words)..where((t) => t.id.equals(guest.id))).go();
        } else {
          // ADOPT: No conflict. Reassign the existing guest word to the new userId.
          await (update(words)..where((t) => t.id.equals(guest.id))).write(
            WordsCompanion(userId: Value(userId), lastUpdated: Value(now)),
          );
          changedWordIds.add(guest.id);
        }
        adoptedCount++;
      }

      // 4. Enqueue ONLY the migrated/merged items for cloud sync
      for (final wordId in changedWordIds) {
        await enqueueSyncOperation(wordId, 'upsert');
      }

      return adoptedCount;
    });
  }

  Future<void> clearLocalWords(String userId) async {
    await (delete(words)..where((t) => t.userId.equals(userId))).go();
  }

  Future<void> clearGuestWords() async {
    await (delete(words)..where((t) => t.userId.isNull())).go();
  }

  Future<int> getGuestWordsCount() async {
    final countExp = words.id.count();
    final query = selectOnly(words)
      ..addColumns([countExp])
      ..where(words.userId.isNull());
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Stream<int> watchPendingSyncCount() {
    final countExp = wordSyncQueue.id.count();
    final q = selectOnly(wordSyncQueue)..addColumns([countExp]);
    return q.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  Future<int> getPendingSyncCount() async {
    final countExp = wordSyncQueue.id.count();
    final q = selectOnly(wordSyncQueue)..addColumns([countExp]);
    final row = await q.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<void> enqueueSyncOperation(String wordId, String operation) async {
    final now = DateTime.now().toUtc();
    await transaction(() async {
      // 1. Cross-operation idempotency: replace pending conflicts
      // If we are upserting and have a pending delete, or vice versa
      final otherOperation = operation == 'upsert' ? 'delete' : 'upsert';
      await (delete(wordSyncQueue)..where(
            (t) => t.wordId.equals(wordId) & t.operation.equals(otherOperation),
          ))
          .go();

      // 2. Upsert same-operation: update timestamp and reset retry count
      final companion = WordSyncQueueCompanion.insert(
        wordId: wordId,
        operation: operation,
        createdAt: now,
        updatedAt: now,
        retryCount: const Value(0),
        lastError: const Value(null),
      );

      await into(wordSyncQueue).insert(
        companion,
        onConflict: DoUpdate(
          (old) => companion,
          target: [wordSyncQueue.wordId, wordSyncQueue.operation],
        ),
      );
    });
  }

  Future<List<WordSyncQueueData>> getSyncQueue(int limit) async {
    final q = select(wordSyncQueue)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
      ..limit(limit);
    return q.get();
  }

  Future<void> removeFromSyncQueue(int queueId) async {
    await (delete(wordSyncQueue)..where((t) => t.id.equals(queueId))).go();
  }

  Future<void> updateSyncQueueRetry(int queueId, String error) async {
    await customStatement(
      '''
UPDATE word_sync_queue
SET retry_count = retry_count + 1, last_error = ?
WHERE id = ?
''',
      [error, queueId],
    );
  }

  Future<void> clearOrphanedSyncEntries() async {
    await customStatement('''
DELETE FROM word_sync_queue
WHERE word_id NOT IN (SELECT id FROM words)
''');
  }

  Future<String?> getAppSetting(String key) async {
    final query = select(appSettings)..where((t) => t.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<void> upsertAppSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<void> deleteAppSetting(String key) async {
    await (delete(appSettings)..where((t) => t.key.equals(key))).go();
  }

  Future<void> insertDeadLetter({
    required String wordId,
    required String wordText,
    required String operation,
    required String lastError,
    required DateTime failedAt,
  }) async {
    await into(syncDeadLetters).insert(
      SyncDeadLettersCompanion.insert(
        wordId: wordId,
        wordText: wordText,
        operation: operation,
        lastError: lastError,
        failedAt: failedAt,
      ),
    );
  }

  Future<List<SyncDeadLetter>> getUnacknowledgedDeadLetters() {
    final query = (select(syncDeadLetters)
      ..where((t) => t.isAcknowledged.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.failedAt)]));
    return query.get();
  }

  Stream<int> watchUnacknowledgedDeadLetterCount() {
    final countExp = syncDeadLetters.id.count();
    final query = (selectOnly(syncDeadLetters)
      ..addColumns([countExp])
      ..where(syncDeadLetters.isAcknowledged.equals(false)));
    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  Future<SyncDeadLetter?> getDeadLetterById(int id) {
    final query = select(syncDeadLetters)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> acknowledgeDeadLetter(int id) async {
    await (update(syncDeadLetters)..where((t) => t.id.equals(id))).write(
      const SyncDeadLettersCompanion(isAcknowledged: Value(true)),
    );
  }

  Future<bool> verifyIntegrity() async {
    try {
      final result = await customSelect('PRAGMA integrity_check').getSingle();
      return result.data['integrity_check'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyEncryptionKey() async {
    try {
      await customSelect('SELECT count(*) FROM sqlite_master').getSingle();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getDatabaseFilePath() async {
    try {
      final rows = await customSelect('PRAGMA database_list').get();
      for (final row in rows) {
        final name = row.data['name']?.toString();
        if (name == 'main') {
          final path = row.data['file']?.toString();
          if (path != null && path.isNotEmpty) {
            return path;
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

Future<void> _migrate1To2(WordFlowDatabase db) async {
  await db.transaction(() async {
    await db.customStatement('''
CREATE TABLE IF NOT EXISTS words_dedup (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  word_text TEXT NOT NULL,
  total_count INTEGER DEFAULT 1,
  is_known INTEGER DEFAULT 0,
  last_updated TEXT NOT NULL
)
''');

    await db.customStatement('DELETE FROM words_dedup');
    await db.customStatement('''
INSERT INTO words_dedup (id, user_id, word_text, total_count, is_known, last_updated)
SELECT
  (
    SELECT w2.id
    FROM words w2
    WHERE
      (w2.user_id = w.user_id OR (w2.user_id IS NULL AND w.user_id IS NULL))
      AND w2.word_text = w.word_text
    ORDER BY w2.last_updated DESC, w2.id DESC
    LIMIT 1
  ) AS id,
  w.user_id,
  w.word_text,
  SUM(w.total_count) AS total_count,
  MAX(w.is_known) AS is_known,
  MAX(w.last_updated) AS last_updated
FROM words w
GROUP BY w.user_id, w.word_text
''');

    await db.customStatement('DELETE FROM words');
    await db.customStatement('''
INSERT INTO words (id, user_id, word_text, total_count, is_known, last_updated)
SELECT id, user_id, word_text, total_count, is_known, last_updated
FROM words_dedup
''');
    await db.customStatement('DROP TABLE words_dedup');

    await db.clearOrphanedSyncEntries();
  });
}

Future<void> _migrate2To3(WordFlowDatabase db) async {
  await db.customStatement('''
    DELETE FROM words WHERE rowid NOT IN (
      SELECT MIN(rowid) FROM words GROUP BY user_id, word_text
    )
  ''');
  await WordFlowDatabase._createAllIndices(db);
}

Future<void> _migrate3To4(WordFlowDatabase db) async {
  try {
    await db.customStatement(
      'ALTER TABLE word_sync_queue ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime(\'now\'))',
    );
  } catch (e) {
    if (!e.toString().contains('duplicate column name')) {
      rethrow;
    }
  }
}

Future<void> _migrate4To5(WordFlowDatabase db) async {
  await db.transaction(() async {
    // 1. Create temporary table with unique constraint
    await db.customStatement('''
      CREATE TABLE word_sync_queue_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        UNIQUE(word_id, operation)
      );
    ''');

    // 2. Map existing data, grouping to avoid unique violations (keep latest)
    await db.customStatement('''
      INSERT INTO word_sync_queue_new (word_id, operation, retry_count, last_error, created_at, updated_at)
      SELECT word_id, operation, MAX(retry_count), MAX(last_error), MIN(created_at), MAX(updated_at)
      FROM word_sync_queue
      GROUP BY word_id, operation;
    ''');

    // 3. Swap tables
    await db.customStatement('DROP TABLE word_sync_queue;');
    await db.customStatement(
      'ALTER TABLE word_sync_queue_new RENAME TO word_sync_queue;',
    );
  });
}

Future<void> _migrate5To6(WordFlowDatabase db) async {
  await db.transaction(() async {
    // 1. Add foreign key to word_sync_queue by recreating it
    // SQLite doesn't support adding FKs to existing tables.
    await db.customStatement('''
      CREATE TABLE word_sync_queue_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id TEXT NOT NULL REFERENCES words (id) ON DELETE CASCADE,
        operation TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        UNIQUE(word_id, operation)
      );
    ''');

    // Copy data
    await db.customStatement('''
      INSERT INTO word_sync_queue_new (id, word_id, operation, retry_count, last_error, created_at, updated_at)
      SELECT id, word_id, operation, retry_count, last_error, created_at, updated_at FROM word_sync_queue;
    ''');

    // Swap tables
    await db.customStatement('DROP TABLE word_sync_queue;');
    await db.customStatement(
      'ALTER TABLE word_sync_queue_new RENAME TO word_sync_queue;',
    );

    // 2. Ensure all indices exist after table swap.
    await WordFlowDatabase._createAllIndices(db);
  });
}

Future<void> _migrate6To7(WordFlowDatabase db) async {
  await db.transaction(() async {
    await db.customStatement('''
      CREATE TABLE IF NOT EXISTS app_settings (
        "key" TEXT NOT NULL PRIMARY KEY,
        "value" TEXT NOT NULL
      );
    ''');
  });
}

Future<void> _migrate7To8(WordFlowDatabase db) async {
  await db.transaction(() async {
    await WordFlowDatabase._createAllIndices(db);
  });
}

Future<void> _migrate8To9(WordFlowDatabase db) async {
  try {
    await db.customStatement(
      'ALTER TABLE words ADD COLUMN server_timestamp TEXT',
    );
  } catch (e) {
    if (!e.toString().contains('duplicate column name')) {
      rethrow;
    }
  }
}

Future<void> _migrate9To10(WordFlowDatabase db) async {
  await db.customStatement('''
CREATE TABLE IF NOT EXISTS sync_dead_letters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id TEXT NOT NULL,
  word_text TEXT NOT NULL,
  operation TEXT NOT NULL,
  last_error TEXT NOT NULL,
  failed_at TEXT NOT NULL,
  is_acknowledged INTEGER NOT NULL DEFAULT 0
)
''');
}

QueryExecutor _openConnection(String encryptionKey) {
  assert(
    encryptionKey.length == 64 &&
        RegExp(r'^[0-9a-f]+$').hasMatch(encryptionKey),
    'Key must be 64 hex chars',
  );

  final hexKey = encryptionKey;
  return driftDatabase(
    name: 'wordflow',
    native: DriftNativeOptions(
      setup: (rawDb) {
        rawDb.execute("PRAGMA key = \"x'$hexKey'\"");
      },
    ),
  );
}
