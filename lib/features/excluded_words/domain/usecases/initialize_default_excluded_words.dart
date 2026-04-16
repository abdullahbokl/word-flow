import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/excluded_words/data/mappers/excluded_word_mapper.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class InitializeDefaultExcludedWordsUseCase
    extends AsyncUseCase<List<ExcludedWord>, NoParams> {
  InitializeDefaultExcludedWordsUseCase(this.repository);
  final LexiconRepository repository;

  @override
  TaskEither<Failure, List<ExcludedWord>> call(NoParams params) {
    return repository
        .initializeDefaultExcludedWords()
        .map((words) => words.map((w) => w.toExcludedWord()).toList());
  }
}
