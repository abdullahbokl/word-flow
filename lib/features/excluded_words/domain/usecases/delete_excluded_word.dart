import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class DeleteExcludedWordUseCase extends AsyncUseCase<Unit, int> {
  final ExcludedWordsRepository repository;

  DeleteExcludedWordUseCase(this.repository);

  @override
  TaskEither<Failure, Unit> call(int id) {
    return repository.deleteExcludedWord(id);
  }
}
