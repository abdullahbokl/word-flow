import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:lexitrack/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class GetExcludedWordsUseCase extends AsyncUseCase<List<ExcludedWord>, NoParams> {
  final ExcludedWordsRepository repository;

  GetExcludedWordsUseCase(this.repository);

  @override
  TaskEither<Failure, List<ExcludedWord>> call(NoParams params) {
    return repository.getExcludedWords();
  }
}
