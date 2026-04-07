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
  Future<WordRow> updateWord(
    int id, {
    String? meaning,
    String? description,
  });
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
    final q = _buildQuery(filter: filter, query: query, sort: sort);
    return q.get();
  }

  @override
  Stream<List<WordRow>> watchWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  }) {
    final q = _buildQuery(filter: filter, query: query, sort: sort);
    return q.watch();
  }

  Selectable<WordRow> _buildQuery({
    required WordFilter filter,
    required String query,
    required WordSort sort,
  }) {
    final q = _db.select(_db.words);
    if (filter == WordFilter.known) {
      q.where((t) => t.isKnown.equals(true));
    } else if (filter == WordFilter.unknown) {
      q.where((t) => t.isKnown.equals(false));
    }
    if (query.isNotEmpty) {
      q.where((t) => t.word.like('%$query%'));
    }
    _applySorting(q, sort);
    return q;
  }

  void _applySorting(SimpleSelectStatement<dynamic, WordRow> q, WordSort sort) {
    switch (sort) {
      case WordSort.frequencyDesc:
        q.orderBy([
          (t) => OrderingTerm.desc(t.frequency),
          (t) => OrderingTerm.asc(t.word),
        ]);
      case WordSort.frequencyAsc:
        q.orderBy([
          (t) => OrderingTerm.asc(t.frequency),
          (t) => OrderingTerm.asc(t.word),
        ]);
      case WordSort.recent:
        q.orderBy([
          (t) => OrderingTerm.desc(t.updatedAt),
          (t) => OrderingTerm.asc(t.word),
        ]);
      case WordSort.alphabetical:
        q.orderBy([
          (t) => OrderingTerm.asc(t.word),
        ]);
    }
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
  Future<WordRow> updateWord(
    int id, {
    String? meaning,
    String? description,
  }) async {
    final now = DateTime.now();
    await (_db.update(_db.words)..where((w) => w.id.equals(id))).write(
      WordsCompanion(
        meaning: Value(meaning),
        description: Value(description),
        updatedAt: Value(now),
      ),
    );

    final word = await (_db.select(_db.words)
          ..where((w) => w.id.equals(id)))
        .getSingle();

    return word;
  }

  @override
  Future<void> deleteWord(int wordId) async {
    final word = await (_db.select(_db.words)..where((w) => w.id.equals(wordId)))
        .getSingleOrNull();

    if (word == null) return;

    if (word.frequency > 1) {
      // Decrement frequency instead of deleting
      await (_db.update(_db.words)..where((w) => w.id.equals(wordId))).write(
        WordsCompanion(
          frequency: Value(word.frequency - 1),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      // Only delete if frequency reaches 1 or 0
      await (_db.delete(_db.textWordEntries)
            ..where((e) => e.wordId.equals(wordId)))
          .go();
      await (_db.delete(_db.words)..where((w) => w.id.equals(wordId))).go();
    }
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
    final res = await _db
        .customSelect(
            'SELECT COUNT(*) as total, SUM(CASE WHEN is_known = 1 THEN 1 ELSE 0 END) as known FROM words')
        .getSingle();
    final total = res.read<int>('total');
    final known = res.read<int?>('known') ?? 0;
    return LexiconStats(total: total, known: known, unknown: total - known);
  }

  @override
  Stream<LexiconStats> watchStats() {
    return _db
        .customSelect(
            'SELECT COUNT(*) as total, SUM(CASE WHEN is_known = 1 THEN 1 ELSE 0 END) as known FROM words')
        .watchSingle()
        .map((res) {
      final total = res.read<int>('total');
      final known = res.read<int?>('known') ?? 0;
      return LexiconStats(total: total, known: known, unknown: total - known);
    });
  }
}
