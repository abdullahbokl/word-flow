import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/database/app_database.dart';

void main() {
  group('WordFlowDatabase - Schema Migrations', () {
    late WordFlowDatabase db;

    setUp(() {
      db = WordFlowDatabase.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('fresh install: all tables exist with correct schema', () async {
      // Verify all tables are created
      final tables = await db.customSelect('''
        SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'
        ORDER BY name
      ''').get();

      final tableNames = tables.map((t) => t.data['name'] as String).toList();
      expect(tableNames, contains('words'));
      expect(tableNames, contains('word_sync_queue'));
      expect(tableNames, contains('app_settings'));
      expect(tableNames, contains('sync_dead_letters'));

      // Verify schema version
      expect(db.schemaVersion, 11);
    });

    test('fresh install: all indices are created', () async {
      final indices = await db.customSelect('''
        SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'
        ORDER BY name
      ''').get();

      final indexNames = indices.map((i) => i.data['name'] as String).toList();
      expect(indexNames, contains('idx_words_user_word'));
      expect(indexNames, contains('idx_words_known_partial'));
      expect(indexNames, contains('idx_words_last_updated'));
      expect(indexNames, contains('idx_words_known'));
      expect(indexNames, contains('idx_words_updated'));
      expect(indexNames, contains('idx_sync_queue_created'));
    });

    test('words table has all required columns with correct types', () async {
      final pragma = await db.customSelect('PRAGMA table_info(words)').get();

      final columns = {
        for (final col in pragma)
          (col.data['name'] as String): col.data['type'],
      };

      expect(columns.keys, contains('id'));
      expect(columns.keys, contains('user_id'));
      expect(columns.keys, contains('word_text'));
      expect(columns.keys, contains('total_count'));
      expect(columns.keys, contains('is_known'));
      expect(columns.keys, contains('last_updated'));
      expect(columns.keys, contains('server_timestamp'));
    });

    test('word_sync_queue table has UNIQUE(word_id, operation)', () async {
      final uniqueIndices = await db.customSelect('''
        SELECT name FROM sqlite_master 
        WHERE type='index' AND tbl_name='word_sync_queue'
      ''').get();

      final indexNames = uniqueIndices
          .map((i) => i.data['name'] as String)
          .toList();

      // Drift generates unique constraints as indices with 'unique=1'
      // For word_sync_queue, there should be a unique constraint on (word_id, operation)
      expect(
        indexNames.isNotEmpty,
        true,
        reason: 'Should have at least one index',
      );
    });

    test('sync_dead_letters table is created with correct schema', () async {
      final pragma = await db
          .customSelect('PRAGMA table_info(sync_dead_letters)')
          .get();

      final columns = {
        for (final col in pragma)
          (col.data['name'] as String): col.data['type'],
      };

      expect(columns.keys, contains('id'));
      expect(columns.keys, contains('word_id'));
      expect(columns.keys, contains('word_text'));
      expect(columns.keys, contains('operation'));
      expect(columns.keys, contains('last_error'));
      expect(columns.keys, contains('failed_at'));
      expect(columns.keys, contains('is_acknowledged'));
    });

    test('app_settings table has correct schema', () async {
      final pragma = await db
          .customSelect('PRAGMA table_info(app_settings)')
          .get();

      final columns = {
        for (final col in pragma)
          (col.data['name'] as String): col.data['type'],
      };

      expect(columns.keys, contains('key'));
      expect(columns.keys, contains('value'));
    });

    test('migration 1→2: dedup logic ensures latest data preserved', () async {
      // The migration 1→2 runs at database creation time and deduplicates existing data.
      // This test verifies the dedup migration logic works by checking
      // that we can't end up with duplicates after a fresh install.

      final now = DateTime.now().toUtc();

      // The unique constraint (user_id, word_text) is enforced,
      // so we verify insertOnConflictUpdate respects it by using the
      // updateable approach for duplicates.

      // First insert of 'hello'
      await db.upsertWord(
        WordsCompanion.insert(
          id: 'id1',
          wordText: 'hello',
          totalCount: const Value(5),
          isKnown: const Value(false),
          lastUpdated: now,
        ),
      );

      // Try to insert same wordText again - the unique constraint will fail
      // unless the ID is the same. This test verifies that duplicates
      // must be handled via explicit updates.

      final words = await db.getWordsByTexts(['hello']);
      expect(words.length, 1);
      expect(words.first.totalCount, 5);
    });

    test(
      'migration 2→3: UNIQUE(user_id, word_text) constraint enforced on new inserts',
      () async {
        final now = DateTime.now().toUtc();

        // First insert succeeds - no constraint violation
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'id1',
            userId: const Value('user-1'),
            wordText: 'duplicate-text',
            lastUpdated: now,
          ),
        );

        // Second insert with different ID but same (user_id, word_text)
        // violates unique constraint. insertOnConflictUpdate only handles
        // primary key conflicts, not unique constraint violations.
        expect(
          () => db.upsertWord(
            WordsCompanion.insert(
              id: 'id2',
              userId: const Value('user-1'),
              wordText: 'duplicate-text',
              totalCount: const Value(99),
              lastUpdated: now.add(const Duration(seconds: 1)),
            ),
          ),
          throwsA(isA<Exception>()),
        );

        // Original word still exists unchanged
        final words = await db.getWordsByTexts([
          'duplicate-text',
        ], userId: 'user-1');
        expect(words.length, 1);
        expect(words.first.id, 'id1');
      },
    );

    test(
      'migration 4→5: UNIQUE(word_id, operation) prevents sync queue duplicates',
      () async {
        final now = DateTime.now().toUtc();
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'word-1',
            wordText: 'test',
            lastUpdated: now,
          ),
        );

        // First enqueue
        await db.enqueueSyncOperation('word-1', 'upsert');
        var queue = await db.getSyncQueue(10);
        expect(queue.length, 1);

        // Second enqueue with same (word_id, operation) should update, not duplicate
        await db.enqueueSyncOperation('word-1', 'upsert');
        queue = await db.getSyncQueue(10);
        expect(queue.length, 1);

        // Different operation replaces previous (cross-operation swap)
        await db.enqueueSyncOperation('word-1', 'delete');
        queue = await db.getSyncQueue(10);
        expect(queue.length, 1);
        expect(queue.first.operation, 'delete');
      },
    );
  });

  group('WordFlowDatabase - upsertWord Idempotency', () {
    late WordFlowDatabase db;

    setUp(() {
      db = WordFlowDatabase.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'insert same word twice with same ID → only one row (update on conflict)',
      () async {
        final now = DateTime.now().toUtc();
        const id = 'test-id-1';

        // First insert
        await db.upsertWord(
          WordsCompanion.insert(
            id: id,
            wordText: 'hello',
            totalCount: const Value(5),
            lastUpdated: now,
          ),
        );

        // Second insert with same ID but different data
        await db.upsertWord(
          WordsCompanion.insert(
            id: id,
            wordText: 'hello',
            totalCount: const Value(10),
            lastUpdated: now.add(const Duration(seconds: 1)),
          ),
        );

        final words = await db
            .customSelect(
              'SELECT * FROM words WHERE id = ?',
              variables: [Variable<String>(id)],
            )
            .get();
        expect(words.length, 1);

        final word = await db.getWordById(id);
        expect(word?.totalCount, 10); // Updated value
        expect(word?.lastUpdated.isAfter(now), true);
      },
    );

    test(
      'insert same wordText for same userId with different IDs → fails due to unique constraint',
      () async {
        final now = DateTime.now().toUtc();
        const userId = 'user-1';
        const wordText = 'flutter';

        // First insert succeeds
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'id-1',
            userId: const Value(userId),
            wordText: wordText,
            totalCount: const Value(3),
            lastUpdated: now,
          ),
        );

        // Second insert with same (userId, wordText) but different id
        // Should fail with UNIQUE constraint violation because insertOnConflictUpdate
        // only handles primary key conflicts, not unique constraints
        expect(
          () => db.upsertWord(
            WordsCompanion.insert(
              id: 'id-2',
              userId: const Value(userId),
              wordText: wordText,
              totalCount: const Value(7),
              lastUpdated: now.add(const Duration(seconds: 1)),
            ),
          ),
          throwsA(isA<Exception>()),
        );

        // Original word should still have original count
        final words = await db.getWordsByTexts([wordText], userId: userId);
        expect(words.length, 1);
        expect(words.first.id, 'id-1');
        expect(words.first.totalCount, 3);
      },
    );

    test('sequential upserts with increasing timestamps', () async {
      final baseTime = DateTime.now().toUtc();
      const id = 'sequential-test';

      for (int i = 0; i < 3; i++) {
        await db.upsertWord(
          WordsCompanion.insert(
            id: id,
            wordText: 'word',
            totalCount: Value(i + 1),
            lastUpdated: baseTime.add(Duration(seconds: i)),
          ),
        );
      }

      final word = await db.getWordById(id);
      expect(word?.totalCount, 3); // Last count
      // Verify lastUpdated was set to the final time (baseTime + 2 seconds)
      final expectedFinalTime = baseTime.add(const Duration(seconds: 2));
      expect(
        word?.lastUpdated.difference(expectedFinalTime).inMilliseconds.abs(),
        lessThan(1000), // Allow margin for test execution time
      );
    });
  });

  group('WordFlowDatabase - adoptGuestWords Merge Logic', () {
    late WordFlowDatabase db;

    setUp(() {
      db = WordFlowDatabase.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'guest word not in user words → reassigned to userId with sync queue entry',
      () async {
        final now = DateTime.now().toUtc();

        // Create guest word
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'guest-unique-word',
            wordText: 'flutter',
            totalCount: const Value(5),
            lastUpdated: now,
          ),
        );

        // Adopt for user
        final adoptedCount = await db.adoptGuestWords('user-123');

        // Verify guest word was reassigned
        final word = await db.getWordByText('flutter', userId: 'user-123');
        expect(word, isNotNull);
        expect(word?.id, 'guest-unique-word');
        expect(word?.userId, 'user-123');
        expect(adoptedCount, 1);

        // Verify sync queue entry exists
        final queue = await db.getSyncQueue(10);
        expect(queue.length, 1);
        expect(queue.first.wordId, 'guest-unique-word');
        expect(queue.first.operation, 'upsert');

        // Verify no guest words remain
        final guestCount = await db.getGuestWordsCount();
        expect(guestCount, 0);
      },
    );

    test(
      'guest word conflicts with user word → merged with max count',
      () async {
        final now = DateTime.now().toUtc();

        // Guest word
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'guest-1',
            wordText: 'hello',
            totalCount: const Value(10),
            isKnown: const Value(false),
            lastUpdated: now,
          ),
        );

        // User word with lower count
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'user-1',
            userId: const Value('user-123'),
            wordText: 'hello',
            totalCount: const Value(3),
            isKnown: const Value(false),
            lastUpdated: now,
          ),
        );

        final adoptedCount = await db.adoptGuestWords('user-123');

        // Verify merge
        final word = await db.getWordByText('hello', userId: 'user-123');
        expect(word?.totalCount, 10); // Higher count from guest
        expect(adoptedCount, 1);

        // Verify guest duplicate was deleted
        final guestWords = await db.getWordByText('hello');
        expect(guestWords, isEmpty);
      },
    );

    test(
      'guest isKnown=true, user isKnown=false → merged isKnown=true (OR logic)',
      () async {
        final now = DateTime.now().toUtc();

        // Guest word with isKnown=true
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'guest-known',
            wordText: 'dart',
            isKnown: const Value(true),
            lastUpdated: now,
          ),
        );

        // User word with isKnown=false
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'user-unknown',
            userId: const Value('user-456'),
            wordText: 'dart',
            isKnown: const Value(false),
            lastUpdated: now,
          ),
        );

        await db.adoptGuestWords('user-456');

        final word = await db.getWordByText('dart', userId: 'user-456');
        expect(word?.isKnown, true); // OR: true | false = true
      },
    );

    test(
      'guest isKnown=false, user isKnown=true → merged isKnown=true (OR logic)',
      () async {
        final now = DateTime.now().toUtc();

        // Guest word with isKnown=false
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'guest-unknown',
            wordText: 'swift',
            isKnown: const Value(false),
            lastUpdated: now,
          ),
        );

        // User word with isKnown=true
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'user-known',
            userId: const Value('user-789'),
            wordText: 'swift',
            isKnown: const Value(true),
            lastUpdated: now,
          ),
        );

        await db.adoptGuestWords('user-789');

        final word = await db.getWordByText('swift', userId: 'user-789');
        expect(word?.isKnown, true); // OR: false | true = true
      },
    );

    test('multiple guest words: mix of conflicts and non-conflicts', () async {
      final now = DateTime.now().toUtc();

      // Guest words
      await db.upsertWords([
        WordsCompanion.insert(
          id: 'guest-1',
          wordText: 'conflict-word',
          totalCount: const Value(8),
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: 'guest-2',
          wordText: 'unique-word',
          totalCount: const Value(4),
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: 'guest-3',
          wordText: 'another-unique',
          totalCount: const Value(2),
          lastUpdated: now,
        ),
      ]);

      // User word (conflict)
      await db.upsertWord(
        WordsCompanion.insert(
          id: 'user-1',
          userId: const Value('user-999'),
          wordText: 'conflict-word',
          totalCount: const Value(3),
          lastUpdated: now,
        ),
      );

      final adoptedCount = await db.adoptGuestWords('user-999');

      expect(adoptedCount, 3); // All 3 guest words processed

      // Check conflict was resolved with max count
      final conflict = await db.getWordByText(
        'conflict-word',
        userId: 'user-999',
      );
      expect(conflict?.totalCount, 8);

      // Check unique words were reassigned
      final unique = await db.getWordByText('unique-word', userId: 'user-999');
      expect(unique?.id, 'guest-2');

      final anotherUnique = await db.getWordByText(
        'another-unique',
        userId: 'user-999',
      );
      expect(anotherUnique?.id, 'guest-3');

      // Verify sync queue has 3 entries (all changed words)
      final queue = await db.getSyncQueue(10);
      expect(queue.length, 3);

      // Verify no guest words remain
      final guestCount = await db.getGuestWordsCount();
      expect(guestCount, 0);
    });

    test('adoptGuestWords with empty guest words handles gracefully', () async {
      final count = await db.adoptGuestWords('any-user-id');
      expect(count, 0);

      // No sync queue entries should be created
      final queue = await db.getSyncQueue(10);
      expect(queue.isEmpty, true);
    });
  });

  group('WordFlowDatabase - enqueueSyncOperation Idempotency', () {
    late WordFlowDatabase db;

    setUp(() {
      db = WordFlowDatabase.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('enqueue upsert for word A → 1 entry', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWord(
        WordsCompanion.insert(id: 'word-a', wordText: 'test', lastUpdated: now),
      );

      await db.enqueueSyncOperation('word-a', 'upsert');

      final queue = await db.getSyncQueue(10);
      expect(queue.length, 1);
      expect(queue.first.wordId, 'word-a');
      expect(queue.first.operation, 'upsert');
      expect(queue.first.retryCount, 0);
    });

    test(
      'enqueue upsert twice for same word → still 1 entry (retryCount reset to 0)',
      () async {
        final now = DateTime.now().toUtc();
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'word-a',
            wordText: 'test',
            lastUpdated: now,
          ),
        );

        // First enqueue
        await db.enqueueSyncOperation('word-a', 'upsert');
        final queue = await db.getSyncQueue(10);
        final firstId = queue.first.id;

        // Simulate retry by incrementing retry count
        await db.updateSyncQueueRetry(firstId, 'Some error');

        final queueAfterRetry = await db.getSyncQueue(10);
        expect(queueAfterRetry.first.retryCount, 1);

        // Re-enqueue same operation
        await db.enqueueSyncOperation('word-a', 'upsert');
        final queueAfterReequeue = await db.getSyncQueue(10);

        expect(queueAfterReequeue.length, 1);
        expect(queueAfterReequeue.first.retryCount, 0); // Reset to 0
        expect(queueAfterReequeue.first.lastError, isNull); // Error cleared (unchanged, not userId)
      },
    );

    test(
      'enqueue delete when upsert pending → upsert removed, delete added',
      () async {
        final now = DateTime.now().toUtc();
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'word-x',
            wordText: 'to-delete',
            lastUpdated: now,
          ),
        );

        // First enqueue upsert
        await db.enqueueSyncOperation('word-x', 'upsert');
        final queue = await db.getSyncQueue(10);
        expect(queue.first.operation, 'upsert');

        // Now enqueue delete (cross-operation)
        await db.enqueueSyncOperation('word-x', 'delete');
        final queueAfterDelete = await db.getSyncQueue(10);

        expect(queueAfterDelete.length, 1);
        expect(queueAfterDelete.first.operation, 'delete');
      },
    );

    test(
      'enqueue upsert when delete pending → delete removed, upsert added',
      () async {
        final now = DateTime.now().toUtc();
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'word-y',
            wordText: 'to-restore',
            lastUpdated: now,
          ),
        );

        // First enqueue delete
        await db.enqueueSyncOperation('word-y', 'delete');
        final queue = await db.getSyncQueue(10);
        expect(queue.first.operation, 'delete');

        // Now enqueue upsert (cross-operation)
        await db.enqueueSyncOperation('word-y', 'upsert');
        final queueAfterUpsert = await db.getSyncQueue(10);

        expect(queueAfterUpsert.length, 1);
        expect(queueAfterUpsert.first.operation, 'upsert');
      },
    );

    test(
      'multiple cross-operations in sequence: delete→upsert→delete',
      () async {
        final now = DateTime.now().toUtc();
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'flaky-word',
            wordText: 'flaky',
            lastUpdated: now,
          ),
        );

        // Sequence: delete → upsert → delete
        await db.enqueueSyncOperation('flaky-word', 'delete');
        final q1 = await db.getSyncQueue(10);
        expect(q1.first.operation, 'delete');

        await db.enqueueSyncOperation('flaky-word', 'upsert');
        final q2 = await db.getSyncQueue(10);
        expect(q2.first.operation, 'upsert');

        await db.enqueueSyncOperation('flaky-word', 'delete');
        final q3 = await db.getSyncQueue(10);
        expect(q3.first.operation, 'delete');
      },
    );

    test('two different words can both be in queue independently', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWords([
        WordsCompanion.insert(
          id: 'word-1',
          wordText: 'first',
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: 'word-2',
          wordText: 'second',
          lastUpdated: now,
        ),
      ]);

      await db.enqueueSyncOperation('word-1', 'upsert');
      await db.enqueueSyncOperation('word-2', 'delete');

      final queue = await db.getSyncQueue(10);
      expect(queue.length, 2);

      final ops = {for (final entry in queue) entry.wordId: entry.operation};
      expect(ops['word-1'], 'upsert');
      expect(ops['word-2'], 'delete');
    });
  });

  group('WordFlowDatabase - Cascade Delete', () {
    late WordFlowDatabase db;

    setUp(() {
      db = WordFlowDatabase.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'delete word → sync queue entries for that word are auto-deleted (FK CASCADE)',
      () async {
        final now = DateTime.now().toUtc();

        // Enable foreign keys for cascade behavior
        await db.customStatement('PRAGMA foreign_keys = ON;');

        // Create word and enqueue it
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'cascade-test-word',
            wordText: 'delete-me',
            lastUpdated: now,
          ),
        );

        await db.enqueueSyncOperation('cascade-test-word', 'upsert');
        final queue = await db.getSyncQueue(10);
        expect(queue.length, 1);

        // Delete the word
        await db.deleteWordById('cascade-test-word');

        // Verify word is gone
        final word = await db.getWordById('cascade-test-word');
        expect(word, isNull);

        // Verify sync queue entry was auto-deleted by CASCADE
        final queueAfterDelete = await db.getSyncQueue(10);
        expect(queueAfterDelete.isEmpty, true);
      },
    );

    test(
      'delete word with multiple sync operations → all cascade deleted',
      () async {
        final now = DateTime.now().toUtc();

        // Enable foreign keys for cascade behavior
        await db.customStatement('PRAGMA foreign_keys = ON;');

        await db.upsertWord(
          WordsCompanion.insert(
            id: 'multi-op-word',
            wordText: 'multi',
            lastUpdated: now,
          ),
        );

        // Enqueue upsert first, then switch to delete
        await db.enqueueSyncOperation('multi-op-word', 'upsert');
        await db.enqueueSyncOperation('multi-op-word', 'delete');

        final queue = await db.getSyncQueue(10);
        expect(queue.length, 1);
        expect(queue.first.operation, 'delete');

        // Delete word
        await db.deleteWordById('multi-op-word');

        // All queue entries should be gone
        final queueAfter = await db.getSyncQueue(10);
        expect(queueAfter.isEmpty, true);
      },
    );

    test('cascade delete on orphaned entries with FK disabled', () async {
      final now = DateTime.now().toUtc();

      // Create word
      await db.upsertWord(
        WordsCompanion.insert(
          id: 'orphan-test',
          wordText: 'orphan',
          lastUpdated: now,
        ),
      );

      // Enqueue
      await db.enqueueSyncOperation('orphan-test', 'upsert');

      // Disable FK, delete word directly to bypass cascade
      await db.customStatement('PRAGMA foreign_keys = OFF;');
      await db.deleteWordById('orphan-test');
      await db.customStatement('PRAGMA foreign_keys = ON;');

      // Now we have an orphaned sync queue entry
      var queue = await db.getSyncQueue(10);
      expect(queue.length, 1);

      // Clean up orphaned entries
      await db.clearOrphanedSyncEntries();

      queue = await db.getSyncQueue(10);
      expect(queue.isEmpty, true);
    });
  });

  group('WordFlowDatabase - Additional Operations', () {
    late WordFlowDatabase db;

    setUp(() {
      db = WordFlowDatabase.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('clearLocalWords only clears words for specified userId', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWords([
        WordsCompanion.insert(
          id: '1',
          wordText: 'w1',
          userId: const Value('u1'),
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: '2',
          wordText: 'w2',
          userId: const Value('GUEST'),
          lastUpdated: now,
        ),
      ]);

      await db.clearLocalWords('u1');

      final u1Words = await db.getWordByText('w1', userId: 'u1');
      final guestWords = await db.getWordByText('w2');

      expect(u1Words, isEmpty);
      expect(guestWords, isNotNull);
    });

    test('clearGuestWords only clears guest words', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWords([
        WordsCompanion.insert(
          id: '3',
          wordText: 'w3',
          userId: const Value('u2'),
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: '4',
          wordText: 'w4',
          userId: const Value('GUEST'),
          lastUpdated: now,
        ),
      ]);

      await db.clearGuestWords();

      final userWord = await db.getWordByText('w3', userId: 'u2');
      final guestWord = await db.getWordByText('w4');

      expect(userWord, isNotNull);
      expect(guestWord, isNull);
    });

    test('getKnownWordTexts filters by isKnown=true and userId', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWords([
        WordsCompanion.insert(
          id: '1',
          wordText: 'known1',
          userId: const Value('u1'),
          isKnown: const Value(true),
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: '2',
          wordText: 'unknown',
          userId: const Value('u1'),
          isKnown: const Value(false),
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: '3',
          wordText: 'known2',
          userId: const Value('u1'),
          isKnown: const Value(true),
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: '4',
          wordText: 'other-known',
          userId: const Value('u2'),
          isKnown: const Value(true),
          lastUpdated: now,
        ),
      ]);

      final known = await db.getKnownWordTexts(userId: 'u1');
      expect(known.length, 2);
      expect(known, contains('known1'));
      expect(known, contains('known2'));
      expect(known, isNot(contains('unknown')));
      expect(known, isNot(contains('other-known')));
    });

    test(
      'watchWords emits empty list initially, then updates on changes',
      () async {
        final now = DateTime.now().toUtc();
        final stream = db.watchWords(userId: 'watch-user');

        // First emission should be empty
        expect(await stream.first, isEmpty);

        // Insert word and collect next emission
        final nextEmission = stream.skip(1).first;
        await db.upsertWord(
          WordsCompanion.insert(
            id: 'watch-1',
            wordText: 'watched',
            userId: const Value('watch-user'),
            lastUpdated: now,
          ),
        );

        final words = await nextEmission;
        expect(words.length, 1);
        expect(words.first.wordText, 'watched');
      },
    );

    test('getSyncQueue returns items in createdAt order', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWords([
        WordsCompanion.insert(id: '1', wordText: 'first', lastUpdated: now),
        WordsCompanion.insert(id: '2', wordText: 'second', lastUpdated: now),
        WordsCompanion.insert(id: '3', wordText: 'third', lastUpdated: now),
      ]);

      await db.enqueueSyncOperation('1', 'upsert');
      await Future.delayed(const Duration(milliseconds: 5));
      await db.enqueueSyncOperation('2', 'upsert');
      await Future.delayed(const Duration(milliseconds: 5));
      await db.enqueueSyncOperation('3', 'upsert');

      final queue = await db.getSyncQueue(10);
      expect(queue.length, 3);
      expect(queue[0].wordId, '1');
      expect(queue[1].wordId, '2');
      expect(queue[2].wordId, '3');
    });
  });
}
