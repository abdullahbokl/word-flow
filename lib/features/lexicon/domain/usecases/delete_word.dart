import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/lexicon_repository.dart';

class DeleteWord extends AsyncUseCase<Unit, int> {
  const DeleteWord(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, Unit> call(int wordId) {
    return _repository.deleteWord(wordId);
  }
}
