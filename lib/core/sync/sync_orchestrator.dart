import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/sync/connectivity_monitor.dart';
import 'package:word_flow/core/sync/sync_status.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';

@lazySingleton
class SyncOrchestrator {
  SyncOrchestrator(
    this._connectivityMonitor,
    this._syncRepository,
    this._authRepository,
    this._logger,
  );

  final ConnectivityMonitor _connectivityMonitor;
  final SyncRepository _syncRepository;
  final AuthRepository _authRepository;
  final AppLogger _logger;

  final _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription? _connectivitySub;
  Timer? _debounceTimer;
  bool _isSyncing = false;

  Stream<SyncStatus> get statusStream => _statusController.stream;

  void start() {
    _statusController.add(const SyncStatus.idle());
    _connectivitySub = _connectivityMonitor.statusStream.listen((status) {
      _debounceTimer?.cancel();
      
      if (status == ConnectivityStatus.online) {
        _statusController.add(const SyncStatus.idle());
        _debounceTimer = Timer(const Duration(seconds: 5), () {
          _performSync();
        });
      } else {
        _statusController.add(const SyncStatus.offline());
      }
    });
  }

  void retrySync() {
    if (_isSyncing) return;
    _debounceTimer?.cancel();
    _performSync();
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;

    final userId = _authRepository.currentUserId;
    if (userId == null) {
      _logger.debug('SyncOrchestrator: User is not authenticated (guest). Skipping sync.');
      return;
    }

    _isSyncing = true;
    _statusController.add(const SyncStatus.syncing());
    _logger.info('SyncOrchestrator: Starting push/pull for user $userId');

    try {
      // 1. Push pending
      final pushResult = await _syncRepository.syncPendingWords();
      bool pushFailed = false;
      pushResult.fold(
        (failure) {
          _logger.error('SyncOrchestrator: push failed - ${failure.message}');
          pushFailed = true;
        },
        (count) => _logger.info('SyncOrchestrator: pushed $count changes'),
      );

      // 2. Pull remote
      final pullResult = await _syncRepository.pullRemoteChanges(userId);
      bool pullFailed = false;
      pullResult.fold(
        (failure) {
          _logger.error('SyncOrchestrator: pull failed - ${failure.message}');
          pullFailed = true;
        },
        (count) => _logger.info('SyncOrchestrator: pulled $count changes'),
      );

      if (pushFailed || pullFailed) {
        _statusController.add(const SyncStatus.error('Sync partially failed'));
      } else {
        _statusController.add(const SyncStatus.idle());
      }
    } catch (error, stackTrace) {
      _logger.error('SyncOrchestrator: Unhandled sync exception', error, stackTrace);
      await Sentry.captureException(error, stackTrace: stackTrace);
      _statusController.add(SyncStatus.error(error.toString()));
    } finally {
      _isSyncing = false;
    }
  }

  @disposeMethod
  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySub?.cancel();
    _statusController.close();
  }
}
