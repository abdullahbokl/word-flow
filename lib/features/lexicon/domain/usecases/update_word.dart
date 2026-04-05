import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/word_entity.dart';
import '../repositories/lexicon_repository.dart';

class UpdateWord {
  const UpdateWord(this._repository);

  final LexiconRepository _repository;

  TaskEither<Failure, WordEntity> call(
    int id, {
    String? meaning,
    String? description,
  }) {
    return _repository.updateWord(id, meaning: meaning, description: description);
  }
}
