import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/lexicon/domain/commands/word_commands.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_repository.dart';

class UpdateWord extends AsyncUseCase<WordEntity, UpdateWordCommand> {
  const UpdateWord(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, WordEntity> call(UpdateWordCommand command) {
    return _repository.updateWord(command);
  }
}
