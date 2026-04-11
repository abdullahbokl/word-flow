import 'package:lexitrack/core/database/app_database.dart';

abstract class ExcludedWordsLocalDataSource {
  Future<List<ExcludedWordRow>> getExcludedWords();
  Future<ExcludedWordRow> addExcludedWord(String word);
  Future<ExcludedWordRow> updateExcludedWord(ExcludedWordRow word);
  Future<void> deleteExcludedWord(int id);
  Future<List<ExcludedWordRow>> addMultipleExcludedWords(List<String> words);
}
