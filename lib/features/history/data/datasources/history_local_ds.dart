import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

abstract interface class HistoryLocalDataSource {
  AppDatabase get db;
  Future<List<AnalyzedTextRow>> getHistory();
  Stream<List<AnalyzedTextRow>> watchHistory();
  Future<void> deleteHistoryItem(int id, {bool deleteUniqueWords = false});
  Future<AnalyzedTextRow?> getHistoryItem(int id);
  Future<List<TypedResult>> getAnalysisWords(int id);
  Stream<List<TypedResult>> watchAnalysisWords(int id);
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  const HistoryLocalDataSourceImpl(this._db);
  final AppDatabase _db;

  @override
  AppDatabase get db => _db;

  @override
  Future<List<AnalyzedTextRow>> getHistory() {
    return (_db.select(_db.analyzedTexts)
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  @override
  Stream<List<AnalyzedTextRow>> watchHistory() {
    return (_db.select(_db.analyzedTexts)
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  @override
  Future<void> deleteHistoryItem(int id, {bool deleteUniqueWords = false}) async {
    await _db.transaction(() async {
      if (deleteUniqueWords) {
        // Find words used IN this text
        final entries = await (_db.select(_db.textWordEntries)
              ..where((e) => e.textId.equals(id)))
            .get();

        for (final entry in entries) {
          // Check if used ELSEWHERE
          final otherUsage = await (_db.select(_db.textWordEntries)
                ..where((e) =>
                    e.wordId.equals(entry.wordId) & e.textId.isNotValue(id)))
              .get();

          if (otherUsage.isEmpty) {
            // Delete the word itself
            await (_db.delete(_db.words)..where((w) => w.id.equals(entry.wordId)))
                .go();
          }
        }
      }

      await (_db.delete(_db.textWordEntries)..where((e) => e.textId.equals(id)))
          .go();
      await (_db.delete(_db.analyzedTexts)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<AnalyzedTextRow?> getHistoryItem(int id) {
    return (_db.select(_db.analyzedTexts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<TypedResult>> getAnalysisWords(int id) {
    return (_db.select(_db.textWordEntries).join([
      innerJoin(_db.words, _db.words.id.equalsExp(_db.textWordEntries.wordId)),
    ])..where(_db.textWordEntries.textId.equals(id)))
        .get();
  }

  @override
  Stream<List<TypedResult>> watchAnalysisWords(int id) {
    return (_db.select(_db.textWordEntries).join([
      innerJoin(_db.words, _db.words.id.equalsExp(_db.textWordEntries.wordId)),
    ])..where(_db.textWordEntries.textId.equals(id)))
        .watch();
  }
}
