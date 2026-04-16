import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class DeleteExcludedWordUseCase extends AsyncUseCase<Unit, int> {
  DeleteExcludedWordUseCase(this.repository);
  final LexiconRepository repository;

  @override
  TaskEither<Failure, Unit> call(int id) {
    return repository.unexcludeWord(id).map((_) => unit);
  }
}
