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
      // 1. Get all words in this analysis and their local frequencies
      final entries = await (_db.select(_db.textWordEntries)
            ..where((e) => e.textId.equals(id)))
          .get();

      for (final entry in entries) {
        // 2. Fetch the corresponding word
        final word = await (_db.select(_db.words)
              ..where((w) => w.id.equals(entry.wordId)))
            .getSingleOrNull();

        if (word != null) {
          final newFrequency = word.frequency - entry.localFrequency;

          if (deleteUniqueWords && newFrequency <= 0) {
            // 3a. Remove the word entirely if "delete everything" is selected and freq hits 0
            await (_db.delete(_db.words)..where((w) => w.id.equals(word.id)))
                .go();
          } else {
            // 3b. Otherwise just decrement the frequency
            await (_db.update(_db.words)..where((w) => w.id.equals(word.id)))
                .write(WordsCompanion(
              frequency: Value(newFrequency < 0 ? 0 : newFrequency),
              updatedAt: Value(DateTime.now()),
            ));
          }
        }
      }

      // 4. Clean up junction entries and the analyzed text record
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
