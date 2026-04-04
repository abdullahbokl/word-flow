import 'package:equatable/equatable.dart';

import '../../domain/entities/history_item.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

final class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryLoaded extends HistoryState {
  const HistoryLoaded(this.items);
  final List<HistoryItem> items;

  @override
  List<Object?> get props => [items];
}

final class HistoryFailure extends HistoryState {
  const HistoryFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
