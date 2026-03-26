import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/script_processor.dart';

part 'workspace_state.freezed.dart';

@freezed
sealed class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState.initial() = _Initial;
  const factory WorkspaceState.processing() = _Processing;
  const factory WorkspaceState.results(List<ProcessedWord> words) = _Results;
  const factory WorkspaceState.error(String message) = _Error;
}
