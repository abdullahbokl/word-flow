import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:word_flow/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Words, AppSettings])
class WordFlowDatabase extends _$WordFlowDatabase {
  WordFlowDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Destructive migration for previous v4 schema - recreate all tables
      await m.deleteTable('words');
      await m.deleteTable('app_settings');
      await m.createAll();
    },
  );

  // Word queries
  Stream<List<WordRow>> watchWords() {
    return select(words).watch();
  }

  Future<int> countWords({String? searchQuery, bool? isKnown}) async {
    final query = select(words)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (searchQuery != null && searchQuery.isNotEmpty) {
          cond = cond & t.wordText.like('%$searchQuery%');
        }
        if (isKnown != null) {
          cond = cond & t.isKnown.equals(isKnown);
        }
        return cond;
      });
    final rows = await query.get();
    return rows.length;
  }

  Future<List<WordRow>> getWordsPaginated({
    required int limit,
    required int offset,
    String? searchQuery,
    bool? isKnown,
  }) {
    final query = select(words)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (searchQuery != null && searchQuery.isNotEmpty) {
          cond = cond & t.wordText.like('%$searchQuery%');
        }
        if (isKnown != null) {
          cond = cond & t.isKnown.equals(isKnown);
        }
        return cond;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.lastUpdated)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  Future<List<String>> getKnownWordTexts() async {
    final query = selectOnly(words)
      ..addColumns([words.wordText])
      ..where(words.isKnown.equals(true));
    final rows = await query.get();
    return rows.map((r) => r.read(words.wordText)!).toList();
  }

  Future<WordRow?> getWordByText(String text) {
    return (select(
      words,
    )..where((t) => t.wordText.equals(text))).getSingleOrNull();
  }

  Future<void> upsertWord(WordsCompanion row) {
    return into(words).insertOnConflictUpdate(row);
  }

  Future<void> upsertWords(List<WordsCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(words, rows);
    });
  }

  Future<void> deleteWordById(String id) {
    return (delete(words)..where((t) => t.id.equals(id))).go();
  }

  // App settings
  Future<String?> getAppSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> upsertAppSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'wordflow');
}
