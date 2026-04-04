import 'package:equatable/equatable.dart';

import '../../domain/entities/analysis_result.dart';

sealed class AnalyzerState extends Equatable {
  const AnalyzerState();

  @override
  List<Object?> get props => [];
}

final class AnalyzerInitial extends AnalyzerState {
  const AnalyzerInitial();
}

final class AnalyzerLoading extends AnalyzerState {
  const AnalyzerLoading();
}

final class AnalyzerSuccess extends AnalyzerState {
  const AnalyzerSuccess(this.result);
  final AnalysisResult result;

  @override
  List<Object?> get props => [result];
}

final class AnalyzerFailure extends AnalyzerState {
  const AnalyzerFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
