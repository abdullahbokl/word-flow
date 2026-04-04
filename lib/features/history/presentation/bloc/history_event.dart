import 'package:equatable/equatable.dart';

import '../../domain/entities/history_item.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

final class LoadHistory extends HistoryEvent {
  const LoadHistory();
}

final class HistoryUpdateReceived extends HistoryEvent {
  const HistoryUpdateReceived(this.items);
  final List<HistoryItem> items;

  @override
  List<Object?> get props => [items];
}

final class HistoryErrorReceived extends HistoryEvent {
  const HistoryErrorReceived(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class DeleteHistoryItemEvent extends HistoryEvent {
  const DeleteHistoryItemEvent(this.id, {this.deleteUniqueWords = false});
  final int id;
  final bool deleteUniqueWords;

  @override
  List<Object?> get props => [id, deleteUniqueWords];
}
