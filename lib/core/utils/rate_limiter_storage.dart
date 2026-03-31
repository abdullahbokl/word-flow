import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/logging/app_logger.dart';

abstract class RateLimiterStorage {
  Future<List<DateTime>> loadAttempts(String key);
  Future<void> saveAttempts(String key, List<DateTime> attempts);
}

@LazySingleton(as: RateLimiterStorage)
class RateLimiterStorageImpl implements RateLimiterStorage {
  RateLimiterStorageImpl(this._db, this._logger);

  static const String _prefix = 'rate_limit_';

  final WordFlowDatabase _db;
  final AppLogger _logger;

  @override
  Future<List<DateTime>> loadAttempts(String key) async {
    try {
      final value = await _db.getAppSetting('$_prefix$key');
      if (value == null || value.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(value);
      if (decoded is! List) {
        _logger.warning(
          'RateLimiterStorage invalid payload type for key=$key: ${decoded.runtimeType}',
          category: LogCategory.database,
        );
        return [];
      }

      final parsed = <DateTime>[];
      for (final item in decoded) {
        if (item is String) {
          final attempt = DateTime.tryParse(item);
          if (attempt != null) {
            parsed.add(attempt);
          }
        }
      }

      parsed.sort((a, b) => a.compareTo(b));
      return parsed;
    } catch (e, stackTrace) {
      // Never block user auth flow due to storage issues.
      _logger.error(
        'RateLimiterStorage load failed for key=$key; falling back to empty attempts',
        error: e,
        stackTrace: stackTrace,
        category: LogCategory.database,
      );
      return [];
    }
  }

  @override
  Future<void> saveAttempts(String key, List<DateTime> attempts) async {
    final payload = jsonEncode(
      attempts.map((a) => a.toUtc().toIso8601String()).toList(growable: false),
    );
    await _db.upsertAppSetting('$_prefix$key', payload);
  }
}
