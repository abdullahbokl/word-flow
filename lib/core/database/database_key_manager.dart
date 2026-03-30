import 'dart:convert';
import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:word_flow/core/errors/exceptions.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/security/security_service.dart';

@lazySingleton
class DatabaseKeyManager {
  DatabaseKeyManager(this._securityService);

  static const String _keyName = 'wordflow_database_key';
  static const int _maxWriteAttempts = 3;
  static const Duration _retryDelay = Duration(milliseconds: 100);
  final SecurityService _securityService;
  final AppLogger _logger = AppLogger();

  Future<String> getOrCreateKey() async {
    final result = await _securityService.read(key: _keyName);
    
    return result.fold(
      (failure) => _generateAndStoreKey(),
      (key) {
        if (key != null && key.isNotEmpty) {
          return key;
        } else {
          return _generateAndStoreKey();
        }
      },
    );
  }

  Future<String> _generateAndStoreKey() async {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final newKey = base64UrlEncode(values);

    await _persistKeyWithRetry(newKey);
    return newKey;
  }

  Future<void> _persistKeyWithRetry(String key) async {
    String? lastFailureMessage;

    // Critical: never return an unpersisted key, otherwise a restart can orphan
    // previously encrypted local data. Retry first, then fail hard.
    for (var attempt = 1; attempt <= _maxWriteAttempts; attempt++) {
      final writeResult = await _securityService.write(key: _keyName, value: key);
      final persisted = writeResult.fold(
        (failure) {
          lastFailureMessage = failure.message;
          _logger.warning(
            'Database key persistence attempt $attempt/$_maxWriteAttempts failed: ${failure.message}',
          );
          return false;
        },
        (_) => true,
      );

      if (persisted) {
        return;
      }

      if (attempt < _maxWriteAttempts) {
        await Future.delayed(_retryDelay);
      }
    }

    final exception = KeyPersistenceException(
      'Failed to persist database encryption key after $_maxWriteAttempts attempts. Last error: ${lastFailureMessage ?? 'Unknown secure storage failure'}',
    );
    final stackTrace = StackTrace.current;

    _logger.error(
      'Database key persistence failed after retries',
      exception,
      stackTrace,
    );
    await Sentry.captureException(exception, stackTrace: stackTrace);

    // Hard-fail so startup can surface a user-visible fatal storage issue.
    throw exception;
  }
}
