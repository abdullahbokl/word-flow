import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/word_entity.dart';
import '../repositories/lexicon_repository.dart';

class AddWordManually extends AsyncUseCase<WordEntity, String> {
  const AddWordManually(this._repository);

  final LexiconRepository _repository;

  TaskEither<Failure, WordEntity> call(String text) {
    final normalized = text.trim().toLowerCase();
    if (normalized.isEmpty || normalized.length < 2) {
      return TaskEither.left(
        const ValidationFailure('Word must be at least 2 characters.'),
      );
    }
    return _repository.addWord(normalized);
  }
}
