import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:lexitrack/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class UpdateExcludedWordUseCase extends AsyncUseCase<ExcludedWord, ExcludedWord> {
  final ExcludedWordsRepository repository;

  UpdateExcludedWordUseCase(this.repository);

  @override
  TaskEither<Failure, ExcludedWord> call(ExcludedWord word) {
    return repository.updateExcludedWord(word);
  }
}
