import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/core/errors/failures.dart';

part 'workspace_state.freezed.dart';

@freezed
sealed class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState.initial() = _Initial;
  const factory WorkspaceState.processing() = _Processing;
  const factory WorkspaceState.results({
    required List<ProcessedWord> words,
    required ScriptSummary summary,
    required TextAnalysisConfig config,
    @Default(<String>{}) Set<String> pendingKnownWords,
    @Default(0) int revision,
    String? lastError,
    Failure? failure,
  }) = _Results;
  const factory WorkspaceState.error(String message, {Failure? failure}) = _Error;
}
