import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_repository.dart';

class ToggleWordStatus extends AsyncUseCase<WordEntity, int> {
  const ToggleWordStatus(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, WordEntity> call(int wordId) {
    return _repository.toggleStatus(wordId);
  }
}
