import '../../../../core/database/app_database.dart';
import 'lexicon_local_ds_mutations.dart';
import 'lexicon_local_ds_query_helpers.dart';
import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';
import 'lexicon_local_ds.dart';

class LexiconLocalDataSourceImpl implements LexiconLocalDataSource {
  const LexiconLocalDataSourceImpl(this._db);

  final AppDatabase _db;

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
    String? meaning,
    String? description,
  }) async {
    return updateWordRow(_db, id, meaning: meaning, description: description);
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
  Future<LexiconStats> getStats() async {
    return getLexiconStats(_db);
  }

  @override
  Stream<LexiconStats> watchStats() {
    return watchLexiconStats(_db);
  }
}
