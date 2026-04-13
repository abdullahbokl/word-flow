import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class InitializeDefaultExcludedWordsUseCase
    extends AsyncUseCase<List<ExcludedWord>, NoParams> {
  InitializeDefaultExcludedWordsUseCase(this.repository);
  final ExcludedWordsRepository repository;

  @override
  TaskEither<Failure, List<ExcludedWord>> call(NoParams params) {
    return repository.initializeDefaultExcludedWords();
  }
}
