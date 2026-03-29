import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/sync/connectivity_monitor.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/sync_pending_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_pending_count.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';
import 'package:word_flow/core/usecases/usecase.dart';

import 'package:word_flow/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

@injectable
class SyncCubit extends Cubit<SyncState> {

  SyncCubit(this._watchPendingCount, this._syncPendingWords, this._connectivityMonitor)
      : super(const SyncState.idle(pendingCount: 0));
      
  final WatchPendingCount _watchPendingCount;
  final SyncPendingWords _syncPendingWords;
  final ConnectivityMonitor _connectivityMonitor;
  
  StreamSubscription<Either<Failure, int>>? _pendingSub;
  StreamSubscription<ConnectivityStatus>? _connectivitySub;
  Timer? _syncDebounce;

  /// Initialize connectivity and pending count listeners
  void init() {
    _startWatching();
  }

  void _startWatching() {
    _pendingSub?.cancel();
    _pendingSub = _watchPendingCount(const NoParams()).listen((result) {
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
    });
    
    // Listen to connectivity changes
    _connectivitySub?.cancel();
    _connectivitySub = _connectivityMonitor.statusStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        _debouncedSync();
      }
    });
  }

  void _debouncedSync() {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(milliseconds: 500), () {
      syncNow();
    });
  }

  /// Call this when new items are added to the sync queue
  void notifyNewSyncItem() {
    _debouncedSync();
  }

  Future<void> syncNow() async {
    // Skip if already syncing
    final isSyncing = state.maybeMap(syncing: (_) => true, orElse: () => false);
    if (isSyncing) return;
    
    // Check connectivity first
    if (!await _connectivityMonitor.isOnline) return;
    
    emit(SyncState.syncing(pendingCount: state.pendingCount));
    final result = await _syncPendingWords(const NoParams());
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
    _connectivitySub?.cancel();
    _syncDebounce?.cancel();
    return super.close();
  }
}
