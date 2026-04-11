import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/excluded_words/domain/entities/excluded_word.dart';

abstract interface class ExcludedWordsRepository {
  TaskEither<Failure, List<ExcludedWord>> getExcludedWords();
  TaskEither<Failure, ExcludedWord> addExcludedWord(String word);
  TaskEither<Failure, ExcludedWord> updateExcludedWord(ExcludedWord word);
  TaskEither<Failure, Unit> deleteExcludedWord(int id);
  TaskEither<Failure, List<ExcludedWord>> initializeDefaultExcludedWords();
}
