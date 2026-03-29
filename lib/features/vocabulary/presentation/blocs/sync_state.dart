import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState.idle({
    required int pendingCount,
    DateTime? lastSyncTime,
  }) = _Idle;
  const factory SyncState.syncing({required int pendingCount}) = _Syncing;
  const factory SyncState.error({
    required int pendingCount,
    required String message,
  }) = _Error;
}
