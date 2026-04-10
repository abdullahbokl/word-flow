import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/common/state/bloc_status.dart';
import '../../../../../core/domain/entities/word_entity.dart';
import '../../../domain/entities/lexicon_stats.dart';
import '../../../domain/entities/word_filter.dart';
import '../../../domain/entities/word_sort.dart';

part 'lexicon_state.freezed.dart';

@freezed
abstract class LexiconState with _$LexiconState {
  const factory LexiconState({
    @Default(BlocStatus.initial()) BlocStatus<List<WordEntity>> status,
    @Default(WordFilter.all) WordFilter filter,
    @Default(WordSort.frequencyDesc) WordSort sort,
    @Default('') String query,
    @Default(LexiconStats(total: 0, known: 0, unknown: 0)) LexiconStats stats,
    @Default(0) int page,
    @Default(false) bool hasReachedMax,
  }) = _LexiconState;
}
