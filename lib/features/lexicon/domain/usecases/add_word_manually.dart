import 'package:fpdart/fpdart.dart';

import '../../../../core/domain/entities/word_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../commands/word_commands.dart';
import '../repositories/lexicon_repository.dart';

class AddWordManually extends AsyncUseCase<WordEntity, AddWordCommand> {
  const AddWordManually(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, WordEntity> call(AddWordCommand command) {
    final normalized = command.text.trim().toLowerCase();
    if (normalized.isEmpty || normalized.length < 2) {
      return TaskEither.left(
        const ValidationFailure('Word must be at least 2 characters.'),
      );
    }
    return _repository.addWord(command.copyWith(text: normalized));
  }
}
