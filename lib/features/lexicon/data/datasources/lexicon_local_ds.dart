import '../../../../core/database/app_database.dart';
import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';

abstract interface class LexiconLocalDataSource {
  Future<List<WordRow>> getWords({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
    int? limit,
    int? offset,
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
