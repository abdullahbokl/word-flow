import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_filter.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_sort.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_repository.dart';

class LexiconQueryParams {
  const LexiconQueryParams({
    this.filter = WordFilter.all,
    this.sort = WordSort.frequencyDesc,
    this.query = '',
    this.limit,
    this.offset,
  });

  final WordFilter filter;
  final WordSort sort;
  final String query;
  final int? limit;
  final int? offset;
}

class GetWords extends AsyncUseCase<List<WordEntity>, LexiconQueryParams> {
  const GetWords(this._repository);

  final LexiconRepository _repository;

  @override
  TaskEither<Failure, List<WordEntity>> call(LexiconQueryParams params) {
    return _repository.getWords(
      filter: params.filter,
      sort: params.sort,
      query: params.query,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
