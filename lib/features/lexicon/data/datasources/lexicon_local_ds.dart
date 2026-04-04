import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';

abstract interface class LexiconLocalDataSource {
  Future<List<WordRow>> getWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  });
  Stream<List<WordRow>> watchWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  });
  Future<WordRow> toggleStatus(int wordId);
  Future<void> deleteWord(int wordId);
  Future<WordRow> addWord(String text);
  Future<LexiconStats> getStats();
  Stream<LexiconStats> watchStats();
}

class LexiconLocalDataSourceImpl implements LexiconLocalDataSource {
  const LexiconLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<WordRow>> getWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  }) {
    final q = _db.select(_db.words);

    if (filter == WordFilter.known) {
      q.where((w) => w.isKnown.equals(true));
    } else if (filter == WordFilter.unknown) {
      q.where((w) => w.isKnown.equals(false));
    }

    if (query.isNotEmpty) {
      q.where((w) => w.word.like('%$query%'));
    }

    _applySorting(q, sort);

    return q.get();
  }

  void _applySorting(Selectable<WordRow> q, WordSort sort) {
    if (q is! SimpleSelectStatement) return;
    final statement = q as SimpleSelectStatement<dynamic, WordRow>;

    switch (sort) {
      case WordSort.frequencyDesc:
        statement.orderBy([
          (w) => OrderingTerm.desc(w.frequency),
          (w) => OrderingTerm.asc(w.word),
        ]);
      case WordSort.frequencyAsc:
        statement.orderBy([
          (w) => OrderingTerm.asc(w.frequency),
          (w) => OrderingTerm.asc(w.word),
        ]);
      case WordSort.recent:
        statement.orderBy([
          (w) => OrderingTerm.desc(w.updatedAt),
          (w) => OrderingTerm.asc(w.word),
        ]);
      case WordSort.alphabetical:
        statement.orderBy([
          (w) => OrderingTerm.asc(w.word),
        ]);
    }
  }

  @override
  Stream<List<WordRow>> watchWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  }) {
    final q = _db.select(_db.words);

    if (filter == WordFilter.known) {
      q.where((w) => w.isKnown.equals(true));
    } else if (filter == WordFilter.unknown) {
      q.where((w) => w.isKnown.equals(false));
    }

    if (query.isNotEmpty) {
      q.where((w) => w.word.like('%$query%'));
    }

    _applySorting(q, sort);

    return q.watch();
  }

  @override
  Future<WordRow> toggleStatus(int wordId) async {
    final word = await (_db.select(_db.words)
          ..where((w) => w.id.equals(wordId)))
        .getSingleOrNull();

    if (word == null) {
      throw const DatabaseException('Word not found');
    }

    final now = DateTime.now();
    await (_db.update(_db.words)..where((w) => w.id.equals(wordId)))
        .write(WordsCompanion(
      isKnown: Value(!word.isKnown),
      updatedAt: Value(now),
    ));

    return word.copyWith(isKnown: !word.isKnown, updatedAt: now);
  }

  @override
  Future<void> deleteWord(int wordId) async {
    await (_db.delete(_db.textWordEntries)
          ..where((e) => e.wordId.equals(wordId)))
        .go();
    await (_db.delete(_db.words)..where((w) => w.id.equals(wordId))).go();
  }

  @override
  Future<WordRow> addWord(String text) async {
    final now = DateTime.now();
    final id = await _db.into(_db.words).insert(
          WordsCompanion.insert(
            word: text,
            frequency: const Value(0),
            isKnown: const Value(false),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );

    if (id == 0) {
      throw const DatabaseException('Word already exists');
    }

    return WordRow(
      id: id,
      word: text,
      frequency: 0,
      isKnown: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<LexiconStats> getStats() async {
    final all = await _db.select(_db.words).get();
    final known = all.where((w) => w.isKnown).length;
    return LexiconStats(
      total: all.length,
      known: known,
      unknown: all.length - known,
    );
  }

  @override
  Stream<LexiconStats> watchStats() {
    return _db.select(_db.words).watch().map((all) {
      final known = all.where((w) => w.isKnown).length;
      return LexiconStats(
        total: all.length,
        known: known,
        unknown: all.length - known,
      );
    });
  }
}
