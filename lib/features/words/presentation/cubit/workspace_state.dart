import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:word_flow/features/words/domain/entities/script_analysis.dart';
import 'package:word_flow/features/words/domain/entities/processed_word.dart';

part 'workspace_state.freezed.dart';

@freezed
sealed class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState.initial() = _Initial;
  const factory WorkspaceState.processing() = _Processing;
  const factory WorkspaceState.results({
    required List<ProcessedWord> words,
    required ScriptSummary summary,
    @Default(<String>{}) Set<String> pendingKnownWords,
    @Default(0) int revision,
  }) = _Results;
  const factory WorkspaceState.error(String message) = _Error;
}
