import 'package:wordflow/core/cache/local_cache.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_local_ds.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_local_ds_mutations.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_local_ds_query_helpers.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_sort.dart';
import 'package:rxdart/rxdart.dart';

class LexiconLocalDataSourceImpl implements LexiconLocalDataSource {
  const LexiconLocalDataSourceImpl(this._db, this._cache);

  final AppDatabase _db;
  final LocalCache _cache;

  static const _statsCacheKey = 'lexicon_stats_cache';

  @override
  Future<List<WordRow>> getWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
    int? limit,
    int? offset,
  }) {
    final q = buildWordQuery(
      _db,
      filter: filter,
      query: query,
      sort: sort,
      limit: limit,
      offset: offset,
    );
    return q.get();
  }

  @override
  Stream<List<WordRow>> watchWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  }) {
    final q = buildWordQuery(_db, filter: filter, query: query, sort: sort);
    return q.watch();
  }

  @override
  Future<WordRow> toggleStatus(int wordId) async {
    return toggleWordStatus(_db, wordId);
  }

  @override
  Future<WordRow> updateWord(
    int id, {
    String? text,
    String? meaning,
    String? description,
    List<String>? definitions,
    List<String>? examples,
    List<String>? translations,
    List<String>? synonyms,
    bool? isKnown,
  }) async {
    return updateWordRow(
      _db,
      id,
      text: text,
      meaning: meaning,
      description: description,
      definitions: definitions,
      examples: examples,
      translations: translations,
      synonyms: synonyms,
      isKnown: isKnown,
    );
  }

  @override
  Future<void> deleteWord(int wordId) async {
    await deleteWordRow(_db, wordId);
  }

  @override
  Future<WordRow> addWord(String text) async {
    return addWordRow(_db, text);
  }

  @override
  Future<WordRow> restoreWord(
    String text,
    int previousId,
    int previousFrequency,
    bool wasFullyDeleted,
  ) async {
    return restoreWordRow(
      _db,
      text,
      previousId,
      previousFrequency,
      wasFullyDeleted,
    );
  }

  @override
  Future<WordRow?> getWordByText(String text) async {
    return (_db.select(_db.words)..where((row) => row.word.equals(text)))
        .getSingleOrNull();
  }

  @override
  Future<LexiconStats> getStats() async {
    final stats = await getLexiconStats(_db);
    _saveStatsToCache(stats);
    return stats;
  }

  @override
  Stream<LexiconStats> watchStats() {
    final cached = _getCachedStats();
    final dbStream = watchLexiconStats(_db).map((s) {
      _saveStatsToCache(s);
      return s;
    });

    if (cached != null) {
      return Rx.concat([
        Stream.value(cached),
        dbStream,
      ]).distinct();
    }
    return dbStream;
  }

  LexiconStats? _getCachedStats() {
    final raw = _cache.getString(_statsCacheKey);
    if (raw == null) return null;
    try {
      final parts = raw.split(':');
      if (parts.length != 3) return null;
      return LexiconStats(
        total: int.parse(parts[0]),
        known: int.parse(parts[1]),
        unknown: int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  void _saveStatsToCache(LexiconStats stats) {
    _cache.setString(
        _statsCacheKey, '${stats.total}:${stats.known}:${stats.unknown}');
  }
}
