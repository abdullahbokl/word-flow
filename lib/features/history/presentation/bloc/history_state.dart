import 'package:equatable/equatable.dart';

import '../../../../core/common/state/bloc_status.dart';
import '../../domain/entities/history_item.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.status = const BlocStatus.initial(),
  });

  final BlocStatus<List<HistoryItem>> status;

  HistoryState copyWith({
    BlocStatus<List<HistoryItem>>? status,
  }) {
    return HistoryState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
