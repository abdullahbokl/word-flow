import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:lexitrack/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class InitializeDefaultExcludedWordsUseCase
    extends AsyncUseCase<List<ExcludedWord>, NoParams> {
  final ExcludedWordsRepository repository;

  InitializeDefaultExcludedWordsUseCase(this.repository);

  @override
  TaskEither<Failure, List<ExcludedWord>> call(NoParams params) {
    return repository.initializeDefaultExcludedWords();
  }
}
