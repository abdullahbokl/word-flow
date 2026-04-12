import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_repository.dart';

class GetWordByText extends AsyncUseCase<WordEntity?, String> {
  const GetWordByText(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, WordEntity?> call(String text) {
    return _repository.getWordByText(text);
  }
}
