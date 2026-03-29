import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/sync/connectivity_monitor.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/pull_remote_changes.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/sync_pending_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_pending_count.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';
import 'package:word_flow/core/usecases/usecase.dart';

import 'package:word_flow/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

@injectable
class SyncCubit extends Cubit<SyncState> {

  SyncCubit(
    this._watchPendingCount,
    this._syncPendingWords,
    this._pullRemoteChanges,
    this._authRepository,
    this._connectivityMonitor,
  ) : super(const SyncState.idle(pendingCount: 0));

  final WatchPendingCount _watchPendingCount;
  final SyncPendingWords _syncPendingWords;
  final PullRemoteChanges _pullRemoteChanges;
  final AuthRepository _authRepository;
  final ConnectivityMonitor _connectivityMonitor;
  
  StreamSubscription<Either<Failure, int>>? _pendingSub;
  StreamSubscription<ConnectivityStatus>? _connectivitySub;
  Timer? _syncDebounce;
  Timer? _periodicTimer;
  bool _isInitialized = false;

  /// Initialize connectivity and pending count listeners
  void init() {
    if (_isInitialized) return;
    _isInitialized = true;
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

    // Start 5-minute periodic background sync
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) => syncNow());
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
    
    // Check connectivity first (fast check)
    if (!await _connectivityMonitor.isOnline) return;
    
    // Final app-specific reachability check (HEAD request to Supabase)
    if (!await _connectivityMonitor.checkReachability()) return;
    
    emit(SyncState.syncing(pendingCount: state.pendingCount));
    
    // Phase 1: Push pending local changes
    final pushResult = await _syncPendingWords(const NoParams());
    
    // In case of error in Phase 1, we still might want to try Pull
    // but the SyncState.syncing stays until the end or first failure.
    
    // Phase 2: Pull remote changes (ONLY for authenticated users)
    final userId = _authRepository.currentUserId;
    if (userId != null) {
      final pullResult = await _pullRemoteChanges(userId);
      
      // We combine the results or just look at failures.
      // If push failed but pull succeeds, we might still show error for the push parts?
      // For now, let's just make sure both run if possible.
      
      return pushResult.fold(
        (failure) => emit(SyncState.error(
          pendingCount: state.pendingCount,
          message: 'Push failed: ${failure.message}',
        )),
        (_) => pullResult.fold(
          (failure) => emit(SyncState.error(
            pendingCount: state.pendingCount,
            message: 'Pull failed: ${failure.message}',
          )),
          (_) => emit(SyncState.idle(
            pendingCount: 0,
            lastSyncTime: DateTime.now(),
          )),
        ),
      );
    }

    pushResult.fold(
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
    _periodicTimer?.cancel();
    return super.close();
  }
}
