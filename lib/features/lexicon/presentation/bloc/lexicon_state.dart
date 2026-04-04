import 'package:equatable/equatable.dart';

import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';

sealed class LexiconState extends Equatable {
  const LexiconState();

  @override
  List<Object?> get props => [];
}

final class LexiconInitial extends LexiconState {
  const LexiconInitial();
}

final class LexiconLoading extends LexiconState {
  const LexiconLoading();
}

final class LexiconLoaded extends LexiconState {
  const LexiconLoaded({
    required this.words,
    this.filter = WordFilter.all,
    this.sort = WordSort.frequencyDesc,
    this.query = '',
    this.stats = const LexiconStats.empty(),
  });

  final List<WordEntity> words;
  final WordFilter filter;
  final WordSort sort;
  final String query;
  final LexiconStats stats;

  LexiconLoaded copyWith({
    List<WordEntity>? words,
    WordFilter? filter,
    WordSort? sort,
    String? query,
    LexiconStats? stats,
  }) {
    return LexiconLoaded(
      words: words ?? this.words,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      query: query ?? this.query,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [words, filter, sort, query, stats];
}

final class LexiconFailure extends LexiconState {
  const LexiconFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
