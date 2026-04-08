import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/word_entity.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/lexicon_repository.dart';
import 'get_words.dart';

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
