import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/excluded_words/domain/repositories/excluded_words_repository.dart';

class AddExcludedWordUseCase extends AsyncUseCase<ExcludedWord, String> {
  AddExcludedWordUseCase(this.repository);
  final ExcludedWordsRepository repository;

  @override
  TaskEither<Failure, ExcludedWord> call(String word) {
    return repository.addExcludedWord(word);
  }
}
