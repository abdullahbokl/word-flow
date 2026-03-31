import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/utils/rate_limiter.dart';
import 'package:word_flow/core/utils/rate_limiter_storage.dart';

class InMemoryRateLimiterStorage implements RateLimiterStorage {
  final Map<String, List<DateTime>> store = {};

  @override
  Future<List<DateTime>> loadAttempts(String key) async {
    return store[key]?.toList(growable: false) ?? [];
  }

  @override
  Future<void> saveAttempts(String key, List<DateTime> attempts) async {
    store[key] = attempts.toList(growable: false);
  }
}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late InMemoryRateLimiterStorage storage;
  late MockAppLogger logger;

  setUp(() {
    storage = InMemoryRateLimiterStorage();
    logger = MockAppLogger();
  });

  test('tryRecordAttempt() returns true when under limit', () async {
    final limiter = RateLimiter(
      storage: storage,
      storageKey: 'test1',
      logger: logger,
      maxAttempts: 3,
    );

    final ok = await limiter.tryRecordAttempt();
    expect(ok, isTrue);
  });

  test('tryRecordAttempt() returns false when at limit', () async {
    // Pre-populate storage with maxAttempts attempts
    final key = 'test2';
    final now = DateTime.now();
    storage.store[key] = List.generate(3, (i) => now.subtract(Duration(seconds: i)));

    final limiter = RateLimiter(
      storage: storage,
      storageKey: key,
      logger: logger,
      maxAttempts: 3,
    );

    // initialize should load persisted attempts
    await limiter.initialize();

    final ok = await limiter.tryRecordAttempt();
    expect(ok, isFalse);
  });

  test('concurrent tryRecordAttempt() calls do not exceed maxAttempts', () async {
    final key = 'test3';
    final limiter = RateLimiter(
      storage: storage,
      storageKey: key,
      logger: logger,
      maxAttempts: 3,
    );

    // Fire many concurrent attempts
    final futures = List.generate(10, (_) => limiter.tryRecordAttempt());
    final results = await Future.wait(futures);

    final successes = results.where((r) => r).length;
    expect(successes <= 3, isTrue);

    // Ensure storage persisted no more than maxAttempts
    final persisted = storage.store[key] ?? [];
    expect(persisted.length <= 3, isTrue);
  });
}
