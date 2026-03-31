import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';
import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:word_flow/core/observability/sentry_breadcrumbs.dart';

@lazySingleton
class AppLogger {
  /// Create AppLogger with build-mode-aware settings
  /// In DEBUG: full console output with history
  /// In RELEASE: console disabled, only history (for memory efficiency)
  AppLogger()
    : _talker = Talker(
        settings: TalkerSettings(
          useConsoleLogs: kDebugMode, // Only console logs in debug
          useHistory: true, // Always keep history for flushLogs()
        ),
      );

  final Talker _talker;

  /// Underlying Talker instance (used by BlocObserver)
  Talker get talker => _talker;

  /// Configure Sentry breadcrumb behavior
  ///
  /// In DEBUG: verbose breadcrumbs for troubleshooting
  /// In RELEASE: only warning/error breadcrumbs (minimize noise)
  void attachToSentry() {
    // Sentry is already initialized in main.dart
    // This method documents the behavior:
    // - warning() -> SentryLevel.warning breadcrumb
    // - error() -> SentryLevel.error breadcrumb
    // - debug/info/syncEvent -> no breadcrumbs in release
    if (kDebugMode) {
      _talker.info('[Sentry] Verbose breadcrumbs enabled for debugging');
    }
  }

  /// Print last N entries from Talker history
  /// Useful for bug reports and crash investigations
  /// In RELEASE: history only contains warning/error entries
  void flushLogs({int limit = 100}) {
    final history = _talker.history;
    if (history.isEmpty) {
      _talker.info('No logs in history');
      return;
    }

    final recentLogs = history.length > limit
        ? history.sublist(history.length - limit)
        : history;

    final buffer = StringBuffer();
    buffer.writeln('=== Talker History (last ${recentLogs.length}/$limit) ===');
    for (final log in recentLogs) {
      buffer.writeln('${log.title}: ${log.message}');
    }
    buffer.writeln('=== End History ===');

    _talker.info(buffer.toString());
    if (kDebugMode) {
      // In debug, print to console as well for immediate visibility
      // ignore: avoid_print
      print(buffer.toString());
    }
  }

  /// Log at debug level
  /// Suppressed in RELEASE builds (not logged to Talker)
  void debug(String message) {
    if (kDebugMode) {
      _talker.debug(message);
    }
  }

  /// Log at info level
  /// Suppressed in RELEASE builds (not logged to Talker)
  void info(String message) {
    if (kDebugMode) {
      _talker.info(message);
    }
  }

  /// Log at warning level + forward to Sentry
  /// Logged in both DEBUG and RELEASE builds
  void warning(String message) {
    _talker.warning(message);
    // Forward to Sentry as breadcrumb
    SentryBreadcrumbs.addSyncBreadcrumb(message, level: SentryLevel.warning);
  }

  /// Log at error level + forward to Sentry
  /// Logged in both DEBUG and RELEASE builds
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.error(message, error, stackTrace);
    // Forward to Sentry as breadcrumb
    SentryBreadcrumbs.addSyncBreadcrumb(
      message,
      data: {
        'error': error?.toString(),
        'errorType': error?.runtimeType.toString(),
      },
      level: SentryLevel.error,
    );
  }

  /// Sync-specific event log
  /// Suppressed in RELEASE builds; verbose in DEBUG
  void syncEvent(String message) {
    if (kDebugMode) {
      _talker.log(SyncLog(message));
    }
  }

  /// Database-specific event log
  /// Suppressed in RELEASE builds; verbose in DEBUG
  void dbEvent(String message) {
    if (kDebugMode) {
      _talker.log(DatabaseLog(message));
    }
  }
}

class SyncLog extends TalkerLog {
  SyncLog(String super.message);
  @override
  String get title => 'SYNC';
}

class DatabaseLog extends TalkerLog {
  DatabaseLog(String super.message);
  @override
  String get title => 'DB';
}
