import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class DeleteExcludedWordUseCase extends AsyncUseCase<Unit, int> {
  DeleteExcludedWordUseCase(this.repository);
  final ExcludedWordsRepository repository;

  @override
  TaskEither<Failure, Unit> call(int id) {
    return repository.deleteExcludedWord(id);
  }
}
