import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:word_flow/core/errors/failures.dart';

part 'sync_state.freezed.dart';

@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState.idle({
    required int pendingCount,
    DateTime? lastSyncTime,
    Failure? failure,
  }) = _Idle;
  const factory SyncState.syncing({
    required int pendingCount,
    Failure? failure,
  }) = _Syncing;
  const factory SyncState.error({
    required int pendingCount,
    required String message,
    Failure? failure,
  }) = _Error;
}
