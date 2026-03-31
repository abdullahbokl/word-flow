import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry breadcrumb helpers for structured observability.
///
/// Breadcrumbs create a contextual trail of events before an error occurs,
/// enabling production debugging and root cause analysis.
///
/// Usage:
/// ```dart
/// SentryBreadcrumbs.addSyncBreadcrumb(
///   'Push completed',
///   data: {'pushed': 42, 'failed': 1},
/// );
/// ```
class SentryBreadcrumbs {
  // Private constructor — static-only access
  SentryBreadcrumbs._();

  static const String _syncCategory = 'sync';
  static const String _authCategory = 'auth';
  static const String _dbCategory = 'database';
  static const String _networkCategory = 'network';

  /// Add a sync-related breadcrumb.
  ///
  /// Called at key sync lifecycle points:
  /// - Sync started (userId, pendingCount)
  /// - Push completed/failed (count or error)
  /// - Pull started (lastPullTimestamp)
  /// - Pull completed/failed (stats)
  static void addSyncBreadcrumb(
    String message, {
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: _syncCategory,
        level: level,
        data: data,
      ),
    );
  }

  /// Add an auth-related breadcrumb.
  ///
  /// Called on auth state transitions:
  /// - Sign in attempt
  /// - Sign up attempt
  /// - Sign out
  /// - State change (guest → authenticated, etc.)
  static void addAuthBreadcrumb(
    String message, {
    String? userId,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    final breadcrumbData = data ?? <String, dynamic>{};
    if (userId != null) {
      breadcrumbData['userId'] = userId;
    }

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: _authCategory,
        level: level,
        data: breadcrumbData.isNotEmpty ? breadcrumbData : null,
      ),
    );
  }

  /// Add a database-related breadcrumb.
  ///
  /// Called for:
  /// - Sync queue operations
  /// - Migration events
  /// - Dead-letter archival
  static void addDBBreadcrumb(
    String message, {
    String? operation,
    int? rowCount,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    final breadcrumbData = data ?? <String, dynamic>{};
    if (operation != null) {
      breadcrumbData['operation'] = operation;
    }
    if (rowCount != null) {
      breadcrumbData['rowCount'] = rowCount;
    }

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: _dbCategory,
        level: level,
        data: breadcrumbData.isNotEmpty ? breadcrumbData : null,
      ),
    );
  }

  /// Add a network-related breadcrumb.
  ///
  /// Called for:
  /// - API requests (push/pull words)
  /// - Network status changes
  /// - Retry attempts
  static void addNetworkBreadcrumb(
    String message, {
    int? statusCode,
    String? endpoint,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    final breadcrumbData = data ?? <String, dynamic>{};
    if (statusCode != null) {
      breadcrumbData['statusCode'] = statusCode;
    }
    if (endpoint != null) {
      breadcrumbData['endpoint'] = endpoint;
    }

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: _networkCategory,
        level: level,
        data: breadcrumbData.isNotEmpty ? breadcrumbData : null,
      ),
    );
  }

  /// Start a Sentry transaction for background sync.
  ///
  /// Transactions group related breadcrumbs and measure performance.
  /// Must be finished with `transaction.finish()`.
  ///
  /// Usage:
  /// ```dart
  /// final tx = SentryBreadcrumbs.startSyncTransaction();
  /// try {
  ///   // ... sync work
  /// } finally {
  ///   await tx.finish();
  /// }
  /// ```
  static dynamic startSyncTransaction() {
    return Sentry.startTransaction(
      'sync_cycle',
      'background',
      bindToScope: true,
    );
  }

  /// Start a Sentry transaction for auth flow.
  ///
  /// Usage:
  /// ```dart
  /// final tx = SentryBreadcrumbs.startAuthTransaction('sign_up');
  /// try {
  ///   // ... auth work
  /// } finally {
  ///   await tx.finish();
  /// }
  /// ```
  static dynamic startAuthTransaction(String operation) {
    return Sentry.startTransaction(
      'auth_$operation',
      'auth',
      bindToScope: true,
    );
  }

  /// Clear all breadcrumbs (useful for testing).
  static void clear() {
    Sentry.configureScope((scope) {
      scope.clearBreadcrumbs();
    });
  }
}
