import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:word_flow/core/utils/script_processor.dart';

part 'workspace_state.freezed.dart';

@freezed
sealed class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState.initial() = _Initial;
  const factory WorkspaceState.processing() = _Processing;
  const factory WorkspaceState.results({
    required List<ProcessedWord> words,
    required List<ProcessedWord> unknownWords,
    required List<ProcessedWord> knownWords,
  }) = _Results;
  const factory WorkspaceState.error(String message) = _Error;
}
