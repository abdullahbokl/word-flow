import 'package:fpdart/fpdart.dart';

import '../../../../core/domain/entities/word_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../commands/word_commands.dart';
import '../repositories/lexicon_repository.dart';

class UpdateWord extends AsyncUseCase<WordEntity, UpdateWordCommand> {
  const UpdateWord(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, WordEntity> call(UpdateWordCommand command) {
    return _repository.updateWord(command);
  }
}
