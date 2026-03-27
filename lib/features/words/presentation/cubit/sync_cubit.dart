import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/sync_repository.dart';
import 'sync_state.dart';

@injectable
class SyncCubit extends Cubit<SyncState> {
  final SyncRepository _syncRepository;
  StreamSubscription<int>? _pendingSub;

  SyncCubit(this._syncRepository)
      : super(const SyncState.idle(pendingCount: 0)) {
    _startWatching();
  }

  void _startWatching() {
    _pendingSub?.cancel();
    _pendingSub = _syncRepository.watchPendingCount().listen((count) {
      emit(SyncState.idle(
        pendingCount: count,
        lastSyncTime: state.maybeMap(idle: (s) => s.lastSyncTime, orElse: () => null),
      ));
    });
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
  }

  @override
  Future<void> close() {
    _pendingSub?.cancel();
    return super.close();
  }
}
