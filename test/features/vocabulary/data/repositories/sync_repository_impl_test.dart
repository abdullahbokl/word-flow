import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/sync/sync_operation.dart';
import 'package:word_flow/features/vocabulary/data/repositories/sync_repository_impl.dart';
import 'package:word_flow/features/vocabulary/data/models/word_remote_dto.dart';
import 'package:word_flow/core/logging/app_logger.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mock_data.dart';

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockWordLocalSource mockLocal;
  late MockSyncLocalSource mockSync;
  late MockWordRemoteSource mockRemote;
  late MockAppLogger mockLogger;
  late SyncRepositoryImpl repo;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(testWordRow);
    registerFallbackValue(WordRemoteDto.fromJson(const {
      'id': 'fallback',
      'word_text': 'fallback',
      'last_updated': '2024-01-01T00:00:00Z',
    }));
  });

  setUp(() {
    mockLocal = MockWordLocalSource();
    mockSync = MockSyncLocalSource();
    mockRemote = MockWordRemoteSource();
    mockLogger = MockAppLogger();
    repo = SyncRepositoryImpl(mockLocal, mockSync, mockRemote, mockLogger);
  });

  group('getPendingCount', () {
    test('should return count from sync source', () async {
      when(() => mockSync.getSyncQueueCount()).thenAnswer((_) async => 5);

      final result = await repo.getPendingCount();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (count) => expect(count, 5),
      );
    });

    test('should return 0 when no pending items', () async {
      when(() => mockSync.getSyncQueueCount()).thenAnswer((_) async => 0);

      final result = await repo.getPendingCount();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (count) => expect(count, 0),
      );
    });

    test('should return SyncFailure on error', () async {
      when(() => mockSync.getSyncQueueCount())
          .thenThrow(Exception('DB Error'));

      final result = await repo.getPendingCount();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<SyncFailure>()),
        (_) => fail('Expected left'),
      );
    });
  });

  group('watchPendingCount', () {
    test('should emit pending count changes', () async {
      final testStream = Stream.fromIterable([1, 2, 3]);
      when(() => mockSync.watchSyncQueueCount()).thenAnswer((_) => testStream);

      final stream = repo.watchPendingCount();

      expect(stream, isA<Stream<int>>());
      await expectLater(stream, emitsInOrder([1, 2, 3]));
    });
  });

  group('syncPendingWords', () {
    /// Helper to create test sync queue data
    WordSyncQueueData createQueueItem({
      int id = 1,
      String wordId = 'test-id-1',
      String operation = 'upsert',
      int retryCount = 0,
      String? lastError,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return WordSyncQueueData(
        id: id,
        wordId: wordId,
        operation: operation,
        retryCount: retryCount,
        lastError: lastError,
        createdAt: createdAt ?? DateTime(2024, 1, 1),
        updatedAt: updatedAt ?? DateTime.now().toUtc(),
      );
    }

    test('should process queue items in FIFO order', () async {
      final queueItems = [
        createQueueItem(id: 1, wordId: 'word-1', operation: 'upsert'),
        createQueueItem(id: 2, wordId: 'word-2', operation: 'upsert'),
      ];
      when(() => mockSync.getSyncQueue(20)).thenAnswer((_) async => queueItems);
      when(() => mockLocal.getWordById('word-1'))
          .thenAnswer((_) async => testWordRow);
      when(() => mockLocal.getWordById('word-2'))
          .thenAnswer((_) async => testWordRow2);
      when(() => mockRemote.upsertWord(any())).thenAnswer((_) async {});
      when(() => mockSync.removeFromSyncQueue(any())).thenAnswer((_) async {});

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 2),
      );
      // Verify they were processed
      verify(() => mockRemote.upsertWord(any())).called(2);
      verify(() => mockSync.removeFromSyncQueue(any())).called(2);
    });

    test('should successfully sync upsert operations', () async {
      final queueItem = createQueueItem(
        wordId: 'test-id-1',
        operation: SyncOperation.upsert.value,
      );
      when(() => mockSync.getSyncQueue(20))
          .thenAnswer((_) async => [queueItem]);
      when(() => mockLocal.getWordById('test-id-1'))
          .thenAnswer((_) async => testWordRow);
      when(() => mockRemote.upsertWord(any())).thenAnswer((_) async {});
      when(() => mockSync.removeFromSyncQueue(1)).thenAnswer((_) async {});

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 1),
      );
      verify(() => mockRemote.upsertWord(any())).called(1);
      verify(() => mockSync.removeFromSyncQueue(1)).called(1);
    });

    test('should successfully sync delete operations', () async {
      final queueItem = createQueueItem(
        wordId: 'test-id-1',
        operation: SyncOperation.delete.value,
      );
      when(() => mockSync.getSyncQueue(20))
          .thenAnswer((_) async => [queueItem]);
      when(() => mockRemote.deleteWord('test-id-1')).thenAnswer((_) async {});
      when(() => mockSync.removeFromSyncQueue(1)).thenAnswer((_) async {});

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 1),
      );
      verify(() => mockRemote.deleteWord('test-id-1')).called(1);
      verify(() => mockSync.removeFromSyncQueue(1)).called(1);
    });

    test('should increment retry count on failure', () async {
      final queueItem = createQueueItem(
        wordId: 'test-id-1',
        operation: SyncOperation.upsert.value,
        retryCount: 0,
      );
      when(() => mockSync.getSyncQueue(20))
          .thenAnswer((_) async => [queueItem]);
      when(() => mockLocal.getWordById('test-id-1'))
          .thenAnswer((_) async => testWordRow);
      when(() => mockRemote.upsertWord(any()))
          .thenThrow(Exception('Network error'));
      when(() => mockSync.updateSyncQueueRetry(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 0),
      );
      verify(() => mockSync.updateSyncQueueRetry(1, any())).called(1);
    });

    test('should skip items exceeding max retry count (dead letter)', () async {
      final queueItem = createQueueItem(
        wordId: 'test-id-1',
        operation: SyncOperation.upsert.value,
        retryCount: 11, // Exceeds max of 10
      );
      when(() => mockSync.getSyncQueue(20))
          .thenAnswer((_) async => [queueItem]);
      when(() => mockSync.removeFromSyncQueue(1)).thenAnswer((_) async {});

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 0),
      );
      verify(() => mockSync.removeFromSyncQueue(1)).called(1);
      verifyNever(() => mockRemote.upsertWord(any()));
    });

    test('should handle empty queue gracefully', () async {
      when(() => mockSync.getSyncQueue(20))
          .thenAnswer((_) async => []);

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 0),
      );
    });

    test('should respect exponential backoff timing', () async {
      final now = DateTime.now().toUtc();
      // Retry count 3 means backoff of 2^3 = 8 seconds
      final queueItem = createQueueItem(
        wordId: 'test-id-1',
        operation: SyncOperation.upsert.value,
        retryCount: 3,
        updatedAt: now.subtract(const Duration(seconds: 5)), // Only 5 seconds passed
      );
      when(() => mockSync.getSyncQueue(20))
          .thenAnswer((_) async => [queueItem]);

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 0),
      );
      // Should not attempt to sync due to backoff
      verifyNever(() => mockRemote.upsertWord(any()));
    });

    test('should process item when backoff period has elapsed', () async {
      final now = DateTime.now().toUtc();
      // Retry count 2 means backoff of 2^2 = 4 seconds
      final queueItem = createQueueItem(
        wordId: 'test-id-1',
        operation: SyncOperation.upsert.value,
        retryCount: 2,
        updatedAt: now.subtract(const Duration(seconds: 5)), // 5 seconds passed > 4
      );
      when(() => mockSync.getSyncQueue(20))
          .thenAnswer((_) async => [queueItem]);
      when(() => mockLocal.getWordById('test-id-1'))
          .thenAnswer((_) async => testWordRow);
      when(() => mockRemote.upsertWord(any())).thenAnswer((_) async {});
      when(() => mockSync.removeFromSyncQueue(1)).thenAnswer((_) async {});

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 1),
      );
      verify(() => mockRemote.upsertWord(any())).called(1);
    });

    test('should stop processing on first failure', () async {
      final queueItem = createQueueItem(
        wordId: 'test-id-1',
        operation: SyncOperation.upsert.value,
      );
      when(() => mockSync.getSyncQueue(20))
          .thenAnswer((_) async => [queueItem]);
      when(() => mockLocal.getWordById('test-id-1'))
          .thenAnswer((_) async => testWordRow);
      when(() => mockRemote.upsertWord(any()))
          .thenThrow(Exception('Network error'));
      when(() => mockSync.updateSyncQueueRetry(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.syncPendingWords();

      // Failure should be caught and function should return Right
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 0),
      );
      verify(() => mockSync.updateSyncQueueRetry(any(), any())).called(1);
      verifyNever(() => mockSync.removeFromSyncQueue(any()));
    });

    test('should return SyncFailure on critical error', () async {
      when(() => mockSync.getSyncQueue(20))
          .thenThrow(Exception('Critical DB error'));

      final result = await repo.syncPendingWords();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<SyncFailure>()),
        (_) => fail('Expected left'),
      );
    });

    test('should skip upsert if word not found in local store', () async {
      final queueItem = createQueueItem(
        wordId: 'missing-id',
        operation: SyncOperation.upsert.value,
      );
      when(() => mockSync.getSyncQueue(20))
          .thenAnswer((_) async => [queueItem]);
      when(() => mockLocal.getWordById('missing-id'))
          .thenAnswer((_) async => null);
      when(() => mockSync.removeFromSyncQueue(1)).thenAnswer((_) async {});

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 1),
      );
      // Should still remove from queue even if word is not found
      verify(() => mockSync.removeFromSyncQueue(1)).called(1);
      verifyNever(() => mockRemote.upsertWord(any()));
    });
  });
}
