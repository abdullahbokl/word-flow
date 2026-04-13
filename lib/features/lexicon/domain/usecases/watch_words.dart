import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';
import 'package:wordflow/features/lexicon/domain/usecases/get_words.dart';

class WatchWords extends StreamUseCase<List<WordEntity>, LexiconQueryParams> {
  const WatchWords(this._repository);
  final LexiconRepository _repository;

  @override
  Stream<Either<Failure, List<WordEntity>>> call(LexiconQueryParams params) {
    return _repository.watchWords(
      filter: params.filter,
      sort: params.sort,
      query: params.query,
    );
  }
}
