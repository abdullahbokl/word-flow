import 'package:equatable/equatable.dart';
import '../../domain/entities/history_detail.dart';

sealed class HistoryDetailState extends Equatable {
  const HistoryDetailState();

  @override
  List<Object?> get props => [];
}

final class HistoryDetailInitial extends HistoryDetailState {}

final class HistoryDetailLoading extends HistoryDetailState {}

final class HistoryDetailLoaded extends HistoryDetailState {
  const HistoryDetailLoaded(this.detail);
  final HistoryDetail detail;

  @override
  List<Object?> get props => [detail];
}

final class HistoryDetailFailure extends HistoryDetailState {
  const HistoryDetailFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
