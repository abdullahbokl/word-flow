import 'package:drift/drift.dart';

import 'package:wordflow/core/database/app_database.dart';

abstract interface class HistoryLocalDataSource {
  Future<List<AnalyzedTextRow>> getHistory({int? limit, int? offset});
  Stream<List<AnalyzedTextRow>> watchHistory({int? limit, int? offset});
  Future<void> deleteHistoryItem(int id, {bool deleteUniqueWords = false});
  Future<AnalyzedTextRow?> getHistoryItem(int id);
  Stream<AnalyzedTextRow?> watchHistoryItem(int id);
  Future<List<(WordRow, TextWordEntryRow)>> getAnalysisWords(int id);
  Stream<List<(WordRow, TextWordEntryRow)>> watchAnalysisWords(int id);
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  const HistoryLocalDataSourceImpl(this._db);
  final AppDatabase _db;

  @override
  Future<List<AnalyzedTextRow>> getHistory({int? limit, int? offset}) {
    final query = _db.select(_db.analyzedTexts)
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
      ]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.get();
  }

  @override
  Stream<List<AnalyzedTextRow>> watchHistory({int? limit, int? offset}) {
    final query = _db.select(_db.analyzedTexts)
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
      ]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.watch();
  }

  @override
  Future<void> deleteHistoryItem(int id,
      {bool deleteUniqueWords = false}) async {
    await _db.transaction(() async {
      // 1. Get all words and their frequencies in one join
      final query = _db.select(_db.textWordEntries).join([
        innerJoin(
            _db.words, _db.words.id.equalsExp(_db.textWordEntries.wordId)),
      ])
        ..where(_db.textWordEntries.textId.equals(id));

      final results = await query.get();

      await _db.batch((batch) {
        for (final row in results) {
          final word = row.readTable(_db.words);
          final entry = row.readTable(_db.textWordEntries);
          final newFrequency = word.frequency - entry.localFrequency;

          if (deleteUniqueWords && newFrequency <= 0) {
            batch.deleteWhere(_db.words, (w) => w.id.equals(word.id));
          } else {
            batch.update(
              _db.words,
              WordsCompanion(
                frequency: Value(newFrequency < 0 ? 0 : newFrequency),
                updatedAt: Value(DateTime.now()),
              ),
              where: (w) => w.id.equals(word.id),
            );
          }
        }
      });

      // 2. Clean up junction entries and the analyzed text record
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
  Stream<AnalyzedTextRow?> watchHistoryItem(int id) {
    return (_db.select(_db.analyzedTexts)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  @override
  Future<List<(WordRow, TextWordEntryRow)>> getAnalysisWords(int id) async {
    final results = await (_db.select(_db.textWordEntries).join([
      innerJoin(_db.words, _db.words.id.equalsExp(_db.textWordEntries.wordId)),
    ])
          ..where(_db.textWordEntries.textId.equals(id)))
        .get();

    return results
        .map((r) => (
              r.readTable(_db.words),
              r.readTable(_db.textWordEntries),
            ))
        .toList();
  }

  @override
  Stream<List<(WordRow, TextWordEntryRow)>> watchAnalysisWords(int id) {
    return (_db.select(_db.textWordEntries).join([
      innerJoin(_db.words, _db.words.id.equalsExp(_db.textWordEntries.wordId)),
    ])
          ..where(_db.textWordEntries.textId.equals(id)))
        .watch()
        .map((results) => results
            .map((r) => (
                  r.readTable(_db.words),
                  r.readTable(_db.textWordEntries),
                ))
            .toList());
  }
}
