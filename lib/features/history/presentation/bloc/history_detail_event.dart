import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/history_detail.dart';

sealed class HistoryDetailEvent extends Equatable {
  const HistoryDetailEvent();

  @override
  List<Object?> get props => [];
}

final class LoadHistoryDetail extends HistoryDetailEvent {
  const LoadHistoryDetail(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

final class HistoryDetailUpdated extends HistoryDetailEvent {
  const HistoryDetailUpdated(this.result);
  final Either<Failure, HistoryDetail> result;

  @override
  List<Object?> get props => [result];
}
