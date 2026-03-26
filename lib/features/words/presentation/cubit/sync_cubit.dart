import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/sync_repository.dart';
import 'sync_state.dart';

@injectable
class SyncCubit extends Cubit<SyncState> {
  final SyncRepository _syncRepository;
  Timer? _refreshTimer;

  SyncCubit(this._syncRepository)
      : super(const SyncState.idle(pendingCount: 0)) {
    _startPolling();
  }

  void _startPolling() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
    refresh();
  }

  Future<void> refresh() async {
    final result = await _syncRepository.getPendingCount();
    result.fold(
      (failure) => emit(SyncState.error(
        pendingCount: state.pendingCount,
        message: failure.message,
      )),
      (count) => emit(SyncState.idle(
        pendingCount: count,
        lastSyncTime: state.maybeMap(idle: (s) => s.lastSyncTime, orElse: () => null),
      )),
    );
  }

  Future<void> syncNow() async {
    emit(SyncState.syncing(pendingCount: state.pendingCount));
    final result = await _syncRepository.syncPendingWords();
    result.fold(
      (failure) => emit(SyncState.error(
        pendingCount: state.pendingCount,
        message: failure.message,
      )),
      (_) => emit(SyncState.idle(
        pendingCount: 0,
        lastSyncTime: DateTime.now(),
      )),
    );
    await refresh();
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
