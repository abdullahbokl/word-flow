import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class DeleteWord extends AsyncUseCase<Unit, int> {
  const DeleteWord(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, Unit> call(int wordId) {
    return _repository.deleteWord(wordId);
  }
}
