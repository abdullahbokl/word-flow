import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/lexicon_repository.dart';

class DeleteWord {
  const DeleteWord(this._repository);

  final LexiconRepository _repository;

  TaskEither<Failure, Unit> call(int wordId) {
    return _repository.deleteWord(wordId);
  }
}
