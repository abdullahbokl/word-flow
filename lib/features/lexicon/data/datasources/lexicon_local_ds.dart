import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_sort.dart';

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
    String? text,
    String? meaning,
    String? description,
    List<String>? definitions,
    List<String>? examples,
    List<String>? translations,
    List<String>? synonyms,
    bool? isKnown,
  });
  Future<void> deleteWord(int wordId);
  Future<WordRow> addWord(String text);
  Future<WordRow> restoreWord(
    String text,
    int previousId,
    int previousFrequency,
    bool wasFullyDeleted,
  );
  Future<WordRow?> getWordByText(String text);
  Future<LexiconStats> getStats();
  Stream<LexiconStats> watchStats();
}
