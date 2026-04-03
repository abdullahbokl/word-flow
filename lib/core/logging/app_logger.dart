import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';
import 'package:injectable/injectable.dart';

enum LogCategory { database, network, app }

@lazySingleton
class AppLogger {
  AppLogger()
    : _talker = Talker(
        settings: TalkerSettings(useConsoleLogs: kDebugMode, useHistory: true),
      );

  final Talker _talker;

  Talker get talker => _talker;

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
  }

  void debug(String message) {
    if (kDebugMode) {
      _talker.debug(message);
    }
  }

  void info(String message) {
    if (kDebugMode) {
      _talker.info(message);
    }
  }

  void warning(String message, {LogCategory category = LogCategory.app}) {
    _talker.warning('[${category.name}] $message');
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    LogCategory category = LogCategory.app,
  }) {
    _talker.error('[${category.name}] $message', error, stackTrace);
  }
}
