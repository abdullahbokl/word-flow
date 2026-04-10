import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/common/state/bloc_status.dart';
import '../../../domain/entities/history_item.dart';

part 'history_state.freezed.dart';

@freezed
abstract class HistoryState with _$HistoryState {
  const factory HistoryState({
    @Default(BlocStatus.initial()) BlocStatus<List<HistoryItem>> status,
    @Default(0) int page,
    @Default(false) bool hasReachedMax,
  }) = _HistoryState;
}
