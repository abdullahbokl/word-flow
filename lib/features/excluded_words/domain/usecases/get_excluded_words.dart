import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/excluded_words/data/mappers/excluded_word_mapper.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';

class GetExcludedWordsUseCase
    extends AsyncUseCase<List<ExcludedWord>, NoParams> {
  GetExcludedWordsUseCase(this.repository);
  final LexiconRepository repository;

  @override
  TaskEither<Failure, List<ExcludedWord>> call(NoParams params) {
    return repository
        .getWords(filter: WordFilter.excluded)
        .map((words) => words.map((w) => w.toExcludedWord()).toList());
  }

  Stream<Either<Failure, List<ExcludedWord>>> watch() {
    return repository.watchWords(filter: WordFilter.excluded).map(
          (result) => result.map(
            (words) => words.map((w) => w.toExcludedWord()).toList(),
          ),
        );
  }
}
