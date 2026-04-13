import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/lexicon/domain/commands/word_commands.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class UpdateWord extends AsyncUseCase<WordEntity, UpdateWordCommand> {
  const UpdateWord(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, WordEntity> call(UpdateWordCommand command) {
    return _repository.updateWord(command);
  }
}
