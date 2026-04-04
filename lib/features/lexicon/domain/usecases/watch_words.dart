import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/word_entity.dart';
import '../entities/word_filter.dart';
import '../entities/word_sort.dart';
import '../repositories/lexicon_repository.dart';

class WatchWords {
  const WatchWords(this._repository);
  final LexiconRepository _repository;

  Stream<Either<Failure, List<WordEntity>>> call({
    WordFilter filter = WordFilter.all,
    WordSort sort = WordSort.frequencyDesc,
    String query = '',
  }) =>
      _repository.watchWords(filter: filter, sort: sort, query: query);
}
