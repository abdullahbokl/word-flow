import 'package:equatable/equatable.dart';

import '../../../../../core/common/state/bloc_status.dart';
import '../../../../../core/domain/entities/word_entity.dart';
import '../../../domain/entities/lexicon_stats.dart';
import '../../../domain/entities/word_filter.dart';
import '../../../domain/entities/word_sort.dart';

class LexiconState extends Equatable {
  const LexiconState({
    this.status = const BlocStatus.initial(),
    this.filter = WordFilter.all,
    this.sort = WordSort.frequencyDesc,
    this.query = '',
    this.stats = const LexiconStats.empty(),
    this.page = 0,
    this.hasReachedMax = false,
  });

  final BlocStatus<List<WordEntity>> status;
  final WordFilter filter;
  final WordSort sort;
  final String query;
  final LexiconStats stats;
  final int page;
  final bool hasReachedMax;

  LexiconState copyWith({
    BlocStatus<List<WordEntity>>? status,
    WordFilter? filter,
    WordSort? sort,
    String? query,
    LexiconStats? stats,
    int? page,
    bool? hasReachedMax,
  }) {
    return LexiconState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      query: query ?? this.query,
      stats: stats ?? this.stats,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        status,
        filter,
        sort,
        query,
        stats,
        page,
        hasReachedMax,
      ];
}
