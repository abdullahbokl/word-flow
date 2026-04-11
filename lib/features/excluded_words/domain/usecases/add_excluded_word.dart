import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:lexitrack/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class AddExcludedWordUseCase extends AsyncUseCase<ExcludedWord, String> {
  final ExcludedWordsRepository repository;

  AddExcludedWordUseCase(this.repository);

  @override
  TaskEither<Failure, ExcludedWord> call(String word) {
    return repository.addExcludedWord(word);
  }
}
