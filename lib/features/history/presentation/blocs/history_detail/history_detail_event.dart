import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/history/domain/entities/history_detail.dart';

abstract class HistoryDetailEvent extends Equatable {
  const HistoryDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistoryDetail extends HistoryDetailEvent {
  const LoadHistoryDetail(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class HistoryDetailUpdated extends HistoryDetailEvent {
  const HistoryDetailUpdated(this.result);
  final Either<Failure, HistoryDetail> result;
  @override
  List<Object?> get props => [result];
}

class ToggleWordStatusInHistory extends HistoryDetailEvent {
  const ToggleWordStatusInHistory(this.wordId);
  final int wordId;
  @override
  List<Object?> get props => [wordId];
}
