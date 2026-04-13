import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/lexicon/domain/commands/word_commands.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class RestoreWord extends AsyncUseCase<WordEntity, RestoreWordCommand> {
  const RestoreWord(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, WordEntity> call(RestoreWordCommand command) {
    final normalized = command.text.trim().toLowerCase();
    if (normalized.isEmpty || normalized.length < 2) {
      return TaskEither.left(
        const ValidationFailure('Word must be at least 2 characters.'),
      );
    }
    return _repository.restoreWord(
      RestoreWordCommand(
        text: normalized,
        previousId: command.previousId,
        previousFrequency: command.previousFrequency,
        wasFullyDeleted: command.wasFullyDeleted,
      ),
    );
  }
}
