import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/observability/sentry_breadcrumbs.dart';
import 'package:word_flow/core/sync/connectivity_monitor.dart';
import 'package:word_flow/core/sync/sync_status.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';

@lazySingleton
class SyncOrchestrator {
  SyncOrchestrator(
    this._connectivityMonitor,
    this._syncRepository,
    this._syncLocalSource,
    this._authRepository,
    this._logger,
  );

  final ConnectivityMonitor _connectivityMonitor;
  final SyncRepository _syncRepository;
  final SyncLocalSource _syncLocalSource;
  final AuthRepository _authRepository;
  final AppLogger _logger;

  final _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription? _connectivitySub;
  Timer? _debounceTimer;
  Timer? _periodicTimer;
  bool _isSyncing = false;
  bool _isStarted = false;

  Stream<SyncStatus> get statusStream => _statusController.stream;
  // UI consumes pending-count from orchestrator to avoid parallel sync loops.
  Stream<int> get pendingCountStream => _syncLocalSource.watchSyncQueueCount();

  void start() {
    if (_isStarted) {
      return;
    }
    _isStarted = true;

    _statusController.add(const SyncStatus.idle());
    // Single owner of sync scheduling: connectivity + debounce + periodic timer.
    _connectivitySub = _connectivityMonitor.statusStream.listen((status) {
      _debounceTimer?.cancel();

      if (status == ConnectivityStatus.online) {
        _statusController.add(const SyncStatus.idle());
        _updatePeriodicScheduling();
        _debounceTimer = Timer(const Duration(seconds: 5), () {
          retrySync();
        });
      } else {
        _periodicTimer?.cancel();
        _statusController.add(const SyncStatus.offline());
      }
    });
  }

  void retrySync() {
    if (_isSyncing) return;
    _debounceTimer?.cancel();
    _performSync();
  }

  /// Cancels any pending or in-flight sync cycle.
  /// Must be called before clearing local user data (e.g. on sign-out).
  void cancelInFlightSync() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _isSyncing = false;
    _statusController.add(const SyncStatus.idle());
    _logger.info('SyncOrchestrator: sync cancelled (sign-out or manual cancel)');
  }

  void _updatePeriodicScheduling() {
    _periodicTimer?.cancel();

    if (_authRepository.currentUserId == null) {
      _logger.debug(
        'SyncOrchestrator: User is not authenticated. Periodic sync disabled.',
      );
      return;
    }

    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_authRepository.currentUserId == null) {
        _periodicTimer?.cancel();
        return;
      }
      retrySync();
    });
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;

    // NOTE: previously this method tracked `lastPullTime` to avoid re-pulling
    // unchanged data. That variable was unused and caused confusion; it has
    // been intentionally removed. Sync control is handled by `pendingCountStream`
    // and the periodic/debounce scheduling above.

    final userId = _authRepository.currentUserId;
    if (userId == null) {
      _logger.debug(
        'SyncOrchestrator: User is not authenticated (guest). Skipping sync.',
      );
      _periodicTimer?.cancel();
      return;
    }

    _isSyncing = true;
    _statusController.add(const SyncStatus.syncing());
    _logger.info('SyncOrchestrator: Starting push/pull for user $userId');

    // Start Sentry transaction for full sync cycle
    final transaction = SentryBreadcrumbs.startSyncTransaction();

    try {
      // Get pending count for context
      final pendingCount = await _syncLocalSource.getSyncQueueCount();

      // Breadcrumb: Sync started
      SentryBreadcrumbs.addSyncBreadcrumb(
        'Sync cycle started',
        data: {'userId': userId, 'pendingCount': pendingCount},
      );

      // 1. Push pending changes
      _logger.info('SyncOrchestrator: Starting push phase...');
      SentryBreadcrumbs.addSyncBreadcrumb('Push phase started');

      final pushResult = await _syncRepository.syncPendingWords();
      bool pushFailed = false;
      int? pushCount;

      pushResult.fold(
        (failure) {
          _logger.error(
            'SyncOrchestrator: push failed - ${failure.message}',
            error: failure,
            category: LogCategory.sync,
          );
          pushFailed = true;
          // Breadcrumb: Push failed
          SentryBreadcrumbs.addSyncBreadcrumb(
            'Push phase failed',
            data: {'reason': failure.message},
            level: SentryLevel.warning,
          );
        },
        (count) {
          pushCount = count;
          _logger.info('SyncOrchestrator: pushed $count changes');
          // Breadcrumb: Push completed
          SentryBreadcrumbs.addSyncBreadcrumb(
            'Push phase completed',
            data: {'pushedCount': count},
          );
        },
      );

      // 2. Pull remote changes
      _logger.info('SyncOrchestrator: Starting pull phase...');

      SentryBreadcrumbs.addSyncBreadcrumb(
        'Pull phase started',
      );

      final pullResult = await _syncRepository.pullRemoteChanges(userId);
      bool pullFailed = false;
      int? pullCount;

      pullResult.fold(
        (failure) {
          _logger.error(
            'SyncOrchestrator: pull failed - ${failure.message}',
            error: failure,
            category: LogCategory.sync,
          );
          pullFailed = true;
          // Breadcrumb: Pull failed
          SentryBreadcrumbs.addSyncBreadcrumb(
            'Pull phase failed',
            data: {'reason': failure.message},
            level: SentryLevel.warning,
          );
        },
        (count) {
          pullCount = count;
          _logger.info('SyncOrchestrator: pulled $count changes');
          // Breadcrumb: Pull completed
          SentryBreadcrumbs.addSyncBreadcrumb(
            'Pull phase completed',
            data: {'pulledCount': count, 'mergedItemsCount': count},
          );
        },
      );

      if (pushFailed || pullFailed) {
        _logger.warning(
          'SyncOrchestrator: Sync partially failed (push:$pushFailed, pull:$pullFailed)',
          category: LogCategory.sync,
        );
        SentryBreadcrumbs.addSyncBreadcrumb(
          'Sync cycle partially failed',
          data: {
            'pushFailed': pushFailed,
            'pullFailed': pullFailed,
            'pushCount': pushCount ?? 0,
            'pullCount': pullCount ?? 0,
          },
          level: SentryLevel.warning,
        );
        _statusController.add(const SyncStatus.error('Sync partially failed'));
      } else {
        _logger.info('SyncOrchestrator: Sync completed successfully');
        SentryBreadcrumbs.addSyncBreadcrumb(
          'Sync cycle completed successfully',
          data: {
            'pushCount': pushCount ?? 0,
            'pullCount': pullCount ?? 0,
            'totalSyncItems': (pushCount ?? 0) + (pullCount ?? 0),
          },
        );
        _statusController.add(const SyncStatus.idle());
      }
    } catch (error, stackTrace) {
      _logger.error(
        'SyncOrchestrator: Unhandled sync exception',
        error: error,
        stackTrace: stackTrace,
        category: LogCategory.sync,
      );
      SentryBreadcrumbs.addSyncBreadcrumb(
        'Sync cycle failed with exception',
        data: {
          'error': error.toString(),
          'exceptionType': error.runtimeType.toString(),
        },
        level: SentryLevel.error,
      );
      await Sentry.captureException(error, stackTrace: stackTrace);
      _statusController.add(SyncStatus.error(error.toString()));
    } finally {
      _isSyncing = false;
      await transaction.finish();
    }
  }

  @disposeMethod
  void dispose() {
    _periodicTimer?.cancel();
    _debounceTimer?.cancel();
    _connectivitySub?.cancel();
    _statusController.close();
  }
}
