
class RateLimiter {
  RateLimiter({
    this.maxAttempts = 5,
    this.windowDuration = const Duration(minutes: 1),
  });

  final int maxAttempts;
  final Duration windowDuration;

  final List<DateTime> _attempts = [];

  bool canAttempt() {
    _cleanup();
    return _attempts.length < maxAttempts;
  }

  void recordAttempt() {
    _attempts.add(DateTime.now());
  }

  void reset() {
    _attempts.clear();
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
