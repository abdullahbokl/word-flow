import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/excluded_words/data/mappers/excluded_word_mapper.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/lexicon/domain/commands/word_commands.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class AddExcludedWordUseCase extends AsyncUseCase<ExcludedWord, String> {
  AddExcludedWordUseCase(this.repository);
  final LexiconRepository repository;

  @override
  TaskEither<Failure, ExcludedWord> call(String word) {
    return repository
        .addWord(AddWordCommand(text: word, isExcluded: true))
        .map((w) => w.toExcludedWord());
  }
}
