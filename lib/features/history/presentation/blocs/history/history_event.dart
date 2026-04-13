import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordflow/features/history/domain/entities/history_item.dart';

part 'history_event.freezed.dart';

@freezed
abstract class HistoryEvent with _$HistoryEvent {
  const factory HistoryEvent.load() = LoadHistory;
  const factory HistoryEvent.loadMore() = LoadMoreHistory;
  const factory HistoryEvent.updateReceived(
      {required List<HistoryItem> items}) = HistoryUpdateReceived;
  const factory HistoryEvent.errorReceived({required String message}) =
      HistoryErrorReceived;
  const factory HistoryEvent.deleteItem(
    int id, {
    @Default(false) bool deleteUniqueWords,
  }) = DeleteHistoryItemEvent;
}
