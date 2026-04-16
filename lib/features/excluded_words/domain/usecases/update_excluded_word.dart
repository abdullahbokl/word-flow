import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/excluded_words/data/mappers/excluded_word_mapper.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/lexicon/domain/commands/word_commands.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class UpdateExcludedWordUseCase
    extends AsyncUseCase<ExcludedWord, ExcludedWord> {
  UpdateExcludedWordUseCase(this.repository);
  final LexiconRepository repository;

  @override
  TaskEither<Failure, ExcludedWord> call(ExcludedWord word) {
    return repository
        .updateWord(UpdateWordCommand(
          id: word.id!,
          text: word.word,
        ))
        .map((w) => w.toExcludedWord());
  }
}
