import 'package:equatable/equatable.dart';

import 'package:wordflow/core/common/state/bloc_status.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';

class AnalyzerState extends Equatable {
  const AnalyzerState({
    this.status = const BlocStatus.initial(),
  });

  final BlocStatus<AnalysisResult> status;

  AnalyzerState copyWith({
    BlocStatus<AnalysisResult>? status,
  }) {
    return AnalyzerState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
