import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/sync/sync_orchestrator.dart';
import 'package:word_flow/core/sync/sync_status.dart';
import 'package:word_flow/features/auth/domain/entities/auth_state_change.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';

@lazySingleton
class SyncCubit extends Cubit<SyncState> {
  SyncCubit(this._orchestrator, this._authRepository)
    : super(const SyncState.idle(pendingCount: 0));

  final SyncOrchestrator _orchestrator;
  final AuthRepository _authRepository;

  StreamSubscription<int>? _pendingSub;
  StreamSubscription<SyncStatus>? _statusSub;
  StreamSubscription<AuthStateChange>? _authSub;
  Timer? _periodicTimer;
  bool _isInitialized = false;

  /// Initialize connectivity and pending count listeners
  void init() {
    if (_isInitialized) return;
    _isInitialized = true;
    _startWatching();
  }

  void _startWatching() {
    // Consume orchestrator-owned pending stream; cubit does not schedule sync.
    _pendingSub?.cancel();
    _pendingSub = _orchestrator.pendingCountStream.listen((count) {
      emit(
        state.map(
          idle: (s) => SyncState.idle(
            pendingCount: count,
            lastSyncTime: s.lastSyncTime,
            failure: s.failure,
          ),
          syncing: (s) =>
              SyncState.syncing(pendingCount: count, failure: s.failure),
          error: (s) => SyncState.error(
            pendingCount: count,
            message: s.message,
            failure: s.failure,
          ),
        ),
      );
    });

    _statusSub?.cancel();
    // Consume orchestrator status stream; cubit does not execute sync directly.
    _statusSub = _orchestrator.statusStream.listen((status) {
      status.when(
        idle: () {
          final lastSyncTime = state.maybeWhen(
            syncing: (_, __) => DateTime.now(),
            idle: (_, lastSyncTime, __) => lastSyncTime,
            error: (_, __, ___) => state.maybeWhen(
              idle: (_, lastSyncTime, __) => lastSyncTime,
              orElse: () => null,
            ),
            orElse: () => null,
          );
          emit(
            SyncState.idle(
              pendingCount: state.pendingCount,
              lastSyncTime: lastSyncTime,
            ),
          );
        },
        syncing: () {
          emit(SyncState.syncing(pendingCount: state.pendingCount));
        },
        error: (message) {
          emit(
            SyncState.error(
              pendingCount: state.pendingCount,
              message: message,
              failure: SyncFailure(message),
            ),
          );
        },
        offline: () {
          emit(
            SyncState.idle(
              pendingCount: state.pendingCount,
              lastSyncTime: state.maybeWhen(
                idle: (_, lastSyncTime, __) => lastSyncTime,
                orElse: () => null,
              ),
              failure: const ConnectionFailure('Working offline'),
            ),
          );
        },
      );
    });

    _authSub?.cancel();
    _authSub = _authRepository.authStateStream.listen((_) {
      _syncPeriodicTimerWithAuthState();
    });

    _syncPeriodicTimerWithAuthState();
  }

  void _syncPeriodicTimerWithAuthState() {
    if (_authRepository.currentUserId == null) {
      _periodicTimer?.cancel();
      _periodicTimer = null;
      return;
    }

    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_authRepository.currentUserId == null) {
        _periodicTimer?.cancel();
        _periodicTimer = null;
        return;
      }
      _orchestrator.retrySync();
    });
  }

  /// Call this when new items are added to the sync queue
  void notifyNewSyncItem() {
    _orchestrator.retrySync();
  }

  Future<void> syncNow() async {
    if (_authRepository.currentUserId == null && state.pendingCount == 0) {
      return;
    }

    // Manual retry delegates to orchestrator (single sync owner).
    _orchestrator.retrySync();
  }

  @override
  Future<void> close() {
    _pendingSub?.cancel();
    _statusSub?.cancel();
    _authSub?.cancel();
    _periodicTimer?.cancel();
    return super.close();
  }
}
