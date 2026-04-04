import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/word_entity.dart';
import '../repositories/lexicon_repository.dart';

class ToggleWordStatus {
  const ToggleWordStatus(this._repository);

  final LexiconRepository _repository;

  TaskEither<Failure, WordEntity> call(int wordId) {
    return _repository.toggleStatus(wordId);
  }
}
