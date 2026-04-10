import 'package:fpdart/fpdart.dart';

import '../../../../core/domain/entities/word_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/lexicon_repository.dart';

class ToggleWordStatus extends AsyncUseCase<WordEntity, int> {
  const ToggleWordStatus(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, WordEntity> call(int wordId) {
    return _repository.toggleStatus(wordId);
  }
}
