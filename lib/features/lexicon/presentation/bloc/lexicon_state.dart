import 'package:equatable/equatable.dart';

import '../../../../core/common/state/bloc_status.dart';
import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';

class LexiconState extends Equatable {
  const LexiconState({
    this.status = const BlocStatus.initial(),
    this.filter = WordFilter.all,
    this.sort = WordSort.frequencyDesc,
    this.query = '',
    this.stats = const LexiconStats.empty(),
  });

  final BlocStatus<List<WordEntity>> status;
  final WordFilter filter;
  final WordSort sort;
  final String query;
  final LexiconStats stats;

  LexiconState copyWith({
    BlocStatus<List<WordEntity>>? status,
    WordFilter? filter,
    WordSort? sort,
    String? query,
    LexiconStats? stats,
  }) {
    return LexiconState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      query: query ?? this.query,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [status, filter, sort, query, stats];
}
