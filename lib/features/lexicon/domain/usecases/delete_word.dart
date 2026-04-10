import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_repository.dart';

class DeleteWord extends AsyncUseCase<Unit, int> {
  const DeleteWord(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, Unit> call(int wordId) {
    return _repository.deleteWord(wordId);
  }
}
