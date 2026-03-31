import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/utils/rate_limiter_storage.dart';

class RateLimiter {
  RateLimiter({
    required RateLimiterStorage storage,
    required String storageKey,
    required AppLogger logger,
    this.maxAttempts = 5,
    this.windowDuration = const Duration(minutes: 1),
  }) : _storage = storage,
       _storageKey = storageKey,
       _logger = logger;

  final int maxAttempts;
  final Duration windowDuration;
  final RateLimiterStorage _storage;
  final String _storageKey;
  final AppLogger _logger;

  final List<DateTime> _attempts = [];
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      final persisted = await _storage.loadAttempts(_storageKey);
      _attempts
        ..clear()
        ..addAll(persisted);
      _cleanup();

      // Persist cleanup result so stale attempts don't linger forever.
      await _storage.saveAttempts(_storageKey, _attempts);
    } catch (e, stackTrace) {
        _logger.warning(
          'RateLimiter initialize failed for key=$_storageKey: $e',
          category: LogCategory.network,
        );
        _logger.error(
          'RateLimiter initialize fallback to empty attempts',
          error: e,
          stackTrace: stackTrace,
          category: LogCategory.network,
        );
      _attempts.clear();
    }

    _initialized = true;
  }

  bool canAttempt() {
    _cleanup();
    return _attempts.length < maxAttempts;
  }

  Future<void> recordAttempt() async {
    _attempts.add(DateTime.now());
    _cleanup();

    try {
      await _storage.saveAttempts(_storageKey, _attempts);
    } catch (e, stackTrace) {
        _logger.error(
          'Failed to persist rate limiter attempt for key=$_storageKey',
          error: e,
          stackTrace: stackTrace,
          category: LogCategory.network,
        );
    }
  }

  Future<bool> tryRecordAttempt() async {
    _cleanup();
    if (_attempts.length >= maxAttempts) return false;

    _attempts.add(DateTime.now());
    _cleanup();

    try {
      await _storage.saveAttempts(_storageKey, _attempts);
    } catch (e, stackTrace) {
        _logger.error(
          'Failed to persist rate limiter attempt',
          error: e,
          stackTrace: stackTrace,
          category: LogCategory.network,
        );
    }
    return true;
  }

  Future<void> reset() async {
    _attempts.clear();

    try {
      await _storage.saveAttempts(_storageKey, const []);
    } catch (e, stackTrace) {
        _logger.error(
          'Failed to persist rate limiter reset for key=$_storageKey',
          error: e,
          stackTrace: stackTrace,
          category: LogCategory.network,
        );
    }
  }

  Duration? get remainingCooldown {
    _cleanup();
    if (_attempts.length < maxAttempts) return null;

    // Cooldown ends when the first of the blocking attempts slides out of the window
    final oldestBlockingAttempt = _attempts[0];
    final cooldownEnd = oldestBlockingAttempt.add(windowDuration);
    final now = DateTime.now();

    if (now.isAfter(cooldownEnd)) return null;
    return cooldownEnd.difference(now);
  }

  void _cleanup() {
    final now = DateTime.now();
    _attempts.removeWhere(
      (attempt) => now.difference(attempt) > windowDuration,
    );
  }
}
