import 'package:equatable/equatable.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';

sealed class AnalyzerEvent extends Equatable {
  const AnalyzerEvent();

  @override
  List<Object?> get props => [];
}

final class StartAnalysis extends AnalyzerEvent {
  const StartAnalysis({required this.title, required this.content});
  final String title;
  final String content;

  @override
  List<Object?> get props => [title, content];
}

final class ToggleWordStatusInResult extends AnalyzerEvent {
  const ToggleWordStatusInResult({required this.wordId});
  final int wordId;

  @override
  List<Object?> get props => [wordId];
}

final class ResetAnalysis extends AnalyzerEvent {
  const ResetAnalysis();
}

final class SyncCurrentResultWithLexicon extends AnalyzerEvent {
  const SyncCurrentResultWithLexicon();
}

final class AnalysisUpdateReceived extends AnalyzerEvent {
  const AnalysisUpdateReceived(this.result);
  final AnalysisResult result;

  @override
  List<Object?> get props => [result];
}
