import 'package:equatable/equatable.dart';

import '../../../../../core/common/state/bloc_status.dart';
import '../../../domain/entities/history_detail.dart';

class HistoryDetailState extends Equatable {
  const HistoryDetailState({
    this.status = const BlocStatus.initial(),
  });

  final BlocStatus<HistoryDetail> status;

  HistoryDetailState copyWith({
    BlocStatus<HistoryDetail>? status,
  }) {
    return HistoryDetailState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
