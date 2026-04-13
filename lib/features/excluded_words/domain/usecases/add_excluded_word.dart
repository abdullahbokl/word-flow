import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class AddExcludedWordUseCase extends AsyncUseCase<ExcludedWord, String> {
  final ExcludedWordsRepository repository;

  AddExcludedWordUseCase(this.repository);

  @override
  TaskEither<Failure, ExcludedWord> call(String word) {
    return repository.addExcludedWord(word);
  }
}
