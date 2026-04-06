import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/word_entity.dart';
import '../entities/word_filter.dart';
import '../entities/word_sort.dart';
import '../repositories/lexicon_repository.dart';

class GetWords
    extends AsyncUseCase<List<WordEntity>, WordQueryParams> {
  const GetWords(this._repository);

  final LexiconRepository _repository;

  TaskEither<Failure, List<WordEntity>> call({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  }) {
    return _repository.getWords(filter: filter, sort: sort, query: query);
  }
}
