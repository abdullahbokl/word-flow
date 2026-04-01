import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/data/sync/sync_operation.dart';
import 'package:word_flow/features/vocabulary/data/sync/sync_preferences.dart';
import 'package:word_flow/features/vocabulary/data/models/word_remote_dto.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_remote_source.dart';
import 'package:word_flow/features/vocabulary/data/repositories/sync_repository_impl.dart';
import 'package:word_flow/core/logging/app_logger.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mock_data.dart';

class MockAppLogger extends Mock implements AppLogger {}

class MockSyncPreferences extends Mock implements SyncPreferences {}

void main() {
  late MockWordLocalSource mockLocal;
  late MockSyncLocalSource mockSync;
  late MockWordRemoteSource mockRemote;
  late MockSyncDeadLetterSource mockDeadLetters;
  late MockAppLogger mockLogger;
  late MockSyncPreferences mockPreferences;
  late SyncRepositoryImpl repo;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(testWordRow);
    registerFallbackValue(
      WordRemoteDto.fromJson(const {
        'id': 'fallback',
        'word_text': 'fallback',
        'last_updated': '2024-01-01T00:00:00Z',
      }),
    );
  });

  setUp(() {
    mockLocal = MockWordLocalSource();
    mockSync = MockSyncLocalSource();
    mockRemote = MockWordRemoteSource();
    mockDeadLetters = MockSyncDeadLetterSource();
    mockLogger = MockAppLogger();
    mockPreferences = MockSyncPreferences();
    repo = SyncRepositoryImpl(
      mockLocal,
      mockSync,
      mockDeadLetters,
      mockRemote,
      mockPreferences,
      mockLogger,
    );
  });

  group('getPendingCount', () {
    test('should return count from sync source', () async {
      when(() => mockSync.getSyncQueueCount()).thenAnswer((_) async => 5);

      final result = await repo.getPendingCount();

      expect(result.isRight(), true);
      result.fold((_) => fail('Expected right'), (count) => expect(count, 5));
    });

    test('should return 0 when no pending items', () async {
      when(() => mockSync.getSyncQueueCount()).thenAnswer((_) async => 0);

      final result = await repo.getPendingCount();

      expect(result.isRight(), true);
      result.fold((_) => fail('Expected right'), (count) => expect(count, 0));
    });

    test('should return SyncFailure on error', () async {
      when(() => mockSync.getSyncQueueCount()).thenThrow(Exception('DB Error'));

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
      when(
        () => mockLocal.getWordById('word-1'),
      ).thenAnswer((_) async => testWordRow);
      when(
        () => mockLocal.getWordById('word-2'),
      ).thenAnswer((_) async => testWordRow2);
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
      when(
        () => mockSync.getSyncQueue(20),
      ).thenAnswer((_) async => [queueItem]);
      when(
        () => mockLocal.getWordById('test-id-1'),
      ).thenAnswer((_) async => testWordRow);
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
      when(
        () => mockSync.getSyncQueue(20),
      ).thenAnswer((_) async => [queueItem]);
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
      when(
        () => mockSync.getSyncQueue(20),
      ).thenAnswer((_) async => [queueItem]);
      when(
        () => mockLocal.getWordById('test-id-1'),
      ).thenAnswer((_) async => testWordRow);
      when(
        () => mockRemote.upsertWord(any()),
      ).thenThrow(Exception('Network error'));
      when(
        () => mockSync.updateSyncQueueRetry(any(), any()),
      ).thenAnswer((_) async {});

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
      when(
        () => mockSync.getSyncQueue(20),
      ).thenAnswer((_) async => [queueItem]);
      when(
        () => mockLocal.getWordById('test-id-1'),
      ).thenAnswer((_) async => testWordRow);
      when(
        () => mockDeadLetters.addDeadLetter(
          wordId: any(named: 'wordId'),
          wordText: any(named: 'wordText'),
          operation: any(named: 'operation'),
          lastError: any(named: 'lastError'),
          failedAt: any(named: 'failedAt'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockSync.removeFromSyncQueue(1)).thenAnswer((_) async {});

      final result = await repo.syncPendingWords();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (successCount) => expect(successCount, 0),
      );
      verify(
        () => mockDeadLetters.addDeadLetter(
          wordId: 'test-id-1',
          wordText: any(named: 'wordText'),
          operation: 'upsert',
          lastError: any(named: 'lastError'),
          failedAt: any(named: 'failedAt'),
        ),
      ).called(1);
      verify(() => mockSync.removeFromSyncQueue(1)).called(1);
      verifyNever(() => mockRemote.upsertWord(any()));
    });

    test('should handle empty queue gracefully', () async {
      when(() => mockSync.getSyncQueue(20)).thenAnswer((_) async => []);

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
        updatedAt: now.subtract(
          const Duration(seconds: 5),
        ), // Only 5 seconds passed
      );
      when(
        () => mockSync.getSyncQueue(20),
      ).thenAnswer((_) async => [queueItem]);

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
        updatedAt: now.subtract(
          const Duration(seconds: 5),
        ), // 5 seconds passed > 4
      );
      when(
        () => mockSync.getSyncQueue(20),
      ).thenAnswer((_) async => [queueItem]);
      when(
        () => mockLocal.getWordById('test-id-1'),
      ).thenAnswer((_) async => testWordRow);
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
      when(
        () => mockSync.getSyncQueue(20),
      ).thenAnswer((_) async => [queueItem]);
      when(
        () => mockLocal.getWordById('test-id-1'),
      ).thenAnswer((_) async => testWordRow);
      when(
        () => mockRemote.upsertWord(any()),
      ).thenThrow(Exception('Network error'));
      when(
        () => mockSync.updateSyncQueueRetry(any(), any()),
      ).thenAnswer((_) async {});

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
      when(
        () => mockSync.getSyncQueue(20),
      ).thenThrow(Exception('Critical DB error'));

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
      when(
        () => mockSync.getSyncQueue(20),
      ).thenAnswer((_) async => [queueItem]);
      when(
        () => mockLocal.getWordById('missing-id'),
      ).thenAnswer((_) async => null);
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

  group('pullRemoteChanges', () {
    const userId = 'user-1';

    WordRemoteDto remoteDto({
      required String id,
      required String wordText,
      required int totalCount,
      required bool isKnown,
      required DateTime lastUpdated,
      DateTime? serverTimestamp,
    }) {
      return WordRemoteDto(
        id: id,
        userId: userId,
        wordText: wordText,
        totalCount: totalCount,
        isKnown: isKnown,
        lastUpdated: lastUpdated,
        serverTimestamp: serverTimestamp,
      );
    }

    WordRow localRow({
      required String id,
      required String wordText,
      required int totalCount,
      required bool isKnown,
      required DateTime lastUpdated,
      DateTime? serverTimestamp,
    }) {
      return WordRow(
        id: id,
        userId: userId,
        wordText: wordText,
        totalCount: totalCount,
        isKnown: isKnown,
        lastUpdated: lastUpdated,
        serverTimestamp: serverTimestamp,
      );
    }

    test('New remote word not in local -> saved as new', () async {
      final remote = remoteDto(
        id: 'remote-new',
        wordText: 'newword',
        totalCount: 2,
        isKnown: false,
        lastUpdated: DateTime.utc(2025, 1, 1, 10),
        serverTimestamp: DateTime.utc(2025, 1, 1, 10),
      );

      when(
        () => mockPreferences.getLastPullTimestamp(userId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.fetchUserWords(
          userId,
          limit: 500,
          cursorTime: null,
          cursorId: null,
        ),
      ).thenAnswer((_) async => Right(PaginatedSyncResult(words: [remote])));
      when(
        () => mockLocal.getWordsByIds(['remote-new']),
      ).thenAnswer((_) async => {}); // Empty map - no local word
      when(
        () => mockLocal.saveWordsInTransaction(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockPreferences.setLastPullTimestamp(userId, any()),
      ).thenAnswer((_) async {});

      final result = await repo.pullRemoteChanges(userId);

      expect(result, const Right<Failure, int>(1));
      final captured =
          verify(
                () => mockLocal.saveWordsInTransaction(captureAny()),
              ).captured.single
              as List<WordsCompanion>;
      expect(captured, hasLength(1));
      expect(captured.first.id.value, 'remote-new');
      expect(captured.first.totalCount.value, 2);
    });

    test(
      'Remote word exists locally, remote has higher count -> mergedCount takes remote value',
      () async {
        final remote = remoteDto(
          id: 'same-id',
          wordText: 'sync',
          totalCount: 9,
          isKnown: false,
          lastUpdated: DateTime.utc(2025, 1, 2, 10),
          serverTimestamp: DateTime.utc(2025, 1, 2, 10),
        );
        final local = localRow(
          id: 'same-id',
          wordText: 'sync',
          totalCount: 3,
          isKnown: false,
          lastUpdated: DateTime.utc(2025, 1, 1, 10),
          serverTimestamp: DateTime.utc(2025, 1, 1, 10),
        );

        when(
          () => mockPreferences.getLastPullTimestamp(userId),
        ).thenAnswer((_) async => null);
        when(
          () => mockRemote.fetchUserWords(
            userId,
            limit: 500,
            cursorTime: null,
            cursorId: null,
          ),
        ).thenAnswer((_) async => Right(PaginatedSyncResult(words: [remote])));
        when(
          () => mockLocal.getWordsByIds(['same-id']),
        ).thenAnswer((_) async => {'same-id': local});
        when(
          () => mockLocal.saveWordsInTransaction(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockPreferences.setLastPullTimestamp(userId, any()),
        ).thenAnswer((_) async {});

        final result = await repo.pullRemoteChanges(userId);

        expect(result, const Right<Failure, int>(1));
        final captured =
            verify(
                  () => mockLocal.saveWordsInTransaction(captureAny()),
                ).captured.single
                as List<WordsCompanion>;
        expect(captured.single.totalCount.value, 9);
      },
    );

    test(
      'Remote word exists locally, local has higher count -> mergedCount keeps local value',
      () async {
        final remote = remoteDto(
          id: 'same-id',
          wordText: 'sync',
          totalCount: 2,
          isKnown: false,
          lastUpdated: DateTime.utc(2025, 1, 2, 10),
          serverTimestamp: DateTime.utc(2025, 1, 2, 10),
        );
        final local = localRow(
          id: 'same-id',
          wordText: 'sync',
          totalCount: 8,
          isKnown: false,
          lastUpdated: DateTime.utc(2025, 1, 1, 10),
          serverTimestamp: DateTime.utc(2025, 1, 1, 10),
        );

        when(
          () => mockPreferences.getLastPullTimestamp(userId),
        ).thenAnswer((_) async => null);
        when(
          () => mockRemote.fetchUserWords(
            userId,
            limit: 500,
            cursorTime: null,
            cursorId: null,
          ),
        ).thenAnswer((_) async => Right(PaginatedSyncResult(words: [remote])));
        when(
          () => mockLocal.getWordsByIds(['same-id']),
        ).thenAnswer((_) async => {'same-id': local});
        when(
          () => mockLocal.saveWordsInTransaction(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockPreferences.setLastPullTimestamp(userId, any()),
        ).thenAnswer((_) async {});

        final result = await repo.pullRemoteChanges(userId);

        expect(result, const Right<Failure, int>(1));
        final captured =
            verify(
                  () => mockLocal.saveWordsInTransaction(captureAny()),
                ).captured.single
                as List<WordsCompanion>;
        expect(captured.single.totalCount.value, 8);
      },
    );

    test(
      'Remote isKnown=true, local isKnown=false -> merged isKnown=true (OR logic)',
      () async {
        final remote = remoteDto(
          id: 'same-id',
          wordText: 'sync',
          totalCount: 2,
          isKnown: true,
          lastUpdated: DateTime.utc(2025, 1, 2, 10),
          serverTimestamp: DateTime.utc(2025, 1, 2, 10),
        );
        final local = localRow(
          id: 'same-id',
          wordText: 'sync',
          totalCount: 2,
          isKnown: false,
          lastUpdated: DateTime.utc(2025, 1, 1, 10),
          serverTimestamp: DateTime.utc(2025, 1, 1, 10),
        );

        when(
          () => mockPreferences.getLastPullTimestamp(userId),
        ).thenAnswer((_) async => null);
        when(
          () => mockRemote.fetchUserWords(
            userId,
            limit: 500,
            cursorTime: null,
            cursorId: null,
          ),
        ).thenAnswer((_) async => Right(PaginatedSyncResult(words: [remote])));
        when(
          () => mockLocal.getWordsByIds(['same-id']),
        ).thenAnswer((_) async => {'same-id': local});
        when(
          () => mockLocal.saveWordsInTransaction(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockPreferences.setLastPullTimestamp(userId, any()),
        ).thenAnswer((_) async {});

        final result = await repo.pullRemoteChanges(userId);

        expect(result, const Right<Failure, int>(1));
        final captured =
            verify(
                  () => mockLocal.saveWordsInTransaction(captureAny()),
                ).captured.single
                as List<WordsCompanion>;
        expect(captured.single.isKnown.value, isTrue);
      },
    );

    test('Remote newer timestamp -> mergedLastUpdated = remote', () async {
      final remote = remoteDto(
        id: 'same-id',
        wordText: 'sync',
        totalCount: 2,
        isKnown: false,
        lastUpdated: DateTime.utc(2025, 1, 5, 10),
        serverTimestamp: DateTime.utc(2025, 1, 5, 10),
      );
      final local = localRow(
        id: 'same-id',
        wordText: 'sync-old',
        totalCount: 2,
        isKnown: false,
        lastUpdated: DateTime.utc(2025, 1, 1, 10),
        serverTimestamp: DateTime.utc(2025, 1, 1, 10),
      );

      when(
        () => mockPreferences.getLastPullTimestamp(userId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.fetchUserWords(
          userId,
          limit: 500,
          cursorTime: null,
          cursorId: null,
        ),
      ).thenAnswer((_) async => Right(PaginatedSyncResult(words: [remote])));
      when(
        () => mockLocal.getWordsByIds(['same-id']),
      ).thenAnswer((_) async => {'same-id': local});
      when(
        () => mockLocal.saveWordsInTransaction(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockPreferences.setLastPullTimestamp(userId, any()),
      ).thenAnswer((_) async {});

      final result = await repo.pullRemoteChanges(userId);

      expect(result, const Right<Failure, int>(1));
      final captured =
          verify(
                () => mockLocal.saveWordsInTransaction(captureAny()),
              ).captured.single
              as List<WordsCompanion>;
      expect(captured.single.lastUpdated.value, remote.lastUpdated);
    });

    test('Local newer timestamp -> mergedLastUpdated = local', () async {
      final remote = remoteDto(
        id: 'same-id',
        wordText: 'sync-remote',
        totalCount: 5,
        isKnown: false,
        lastUpdated: DateTime.utc(2025, 1, 1, 10),
        serverTimestamp: DateTime.utc(2025, 1, 1, 10),
      );
      final local = localRow(
        id: 'same-id',
        wordText: 'sync-local',
        totalCount: 2,
        isKnown: false,
        lastUpdated: DateTime.utc(2025, 1, 5, 10),
        serverTimestamp: DateTime.utc(2025, 1, 5, 10),
      );

      when(
        () => mockPreferences.getLastPullTimestamp(userId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.fetchUserWords(
          userId,
          limit: 500,
          cursorTime: null,
          cursorId: null,
        ),
      ).thenAnswer((_) async => Right(PaginatedSyncResult(words: [remote])));
      when(
        () => mockLocal.getWordsByIds(['same-id']),
      ).thenAnswer((_) async => {'same-id': local});
      when(
        () => mockLocal.saveWordsInTransaction(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockPreferences.setLastPullTimestamp(userId, any()),
      ).thenAnswer((_) async {});

      final result = await repo.pullRemoteChanges(userId);

      expect(result, const Right<Failure, int>(1));
      final captured =
          verify(
                () => mockLocal.saveWordsInTransaction(captureAny()),
              ).captured.single
              as List<WordsCompanion>;
      expect(captured.single.lastUpdated.value, local.lastUpdated);
    });

    test('No changes needed -> skippedCount increments', () async {
      final now = DateTime.utc(2025, 2, 1, 10);
      final remote = remoteDto(
        id: 'same-id',
        wordText: 'sync',
        totalCount: 3,
        isKnown: true,
        lastUpdated: now,
        serverTimestamp: now,
      );
      final local = localRow(
        id: 'same-id',
        wordText: 'sync',
        totalCount: 3,
        isKnown: true,
        lastUpdated: now,
        serverTimestamp: now,
      );

      when(
        () => mockPreferences.getLastPullTimestamp(userId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.fetchUserWords(
          userId,
          limit: 500,
          cursorTime: null,
          cursorId: null,
        ),
      ).thenAnswer((_) async => Right(PaginatedSyncResult(words: [remote])));
      when(
        () => mockLocal.getWordsByIds(['same-id']),
      ).thenAnswer((_) async => {'same-id': local});
      when(
        () => mockPreferences.setLastPullTimestamp(userId, any()),
      ).thenAnswer((_) async {});

      final result = await repo.pullRemoteChanges(userId);

      expect(result, const Right<Failure, int>(0));
      verifyNever(() => mockLocal.saveWordsInTransaction(any()));
    });

    test('lastPullTimestamp updated ONLY after successful save', () async {
      final remote = remoteDto(
        id: 'remote-new',
        wordText: 'newword',
        totalCount: 2,
        isKnown: false,
        lastUpdated: DateTime.utc(2025, 1, 1, 10),
        serverTimestamp: DateTime.utc(2025, 1, 1, 10),
      );

      when(
        () => mockPreferences.getLastPullTimestamp(userId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.fetchUserWords(
          userId,
          limit: 500,
          cursorTime: null,
          cursorId: null,
        ),
      ).thenAnswer((_) async => Right(PaginatedSyncResult(words: [remote])));
      when(
        () => mockLocal.getWordsByIds(['remote-new']),
      ).thenAnswer((_) async => {});
      when(
        () => mockLocal.saveWordsInTransaction(any()),
      ).thenThrow(Exception('transaction failed'));

      final result = await repo.pullRemoteChanges(userId);

      expect(
        result,
        const Left<Failure, int>(SyncFailure('Pull transaction failed')),
      );
      verifyNever(() => mockPreferences.setLastPullTimestamp(userId, any()));
    });

    test(
      'Remote source returns Left -> pullRemoteChanges returns Left',
      () async {
        const remoteFailure = ServerFailure('upstream down');
        when(
          () => mockPreferences.getLastPullTimestamp(userId),
        ).thenAnswer((_) async => null);
        when(
          () => mockRemote.fetchUserWords(
            userId,
            limit: 500,
            cursorTime: null,
            cursorId: null,
          ),
        ).thenAnswer((_) async => const Left(remoteFailure));

        final result = await repo.pullRemoteChanges(userId);

        expect(result, const Left<Failure, int>(remoteFailure));
        verifyNever(() => mockPreferences.setLastPullTimestamp(userId, any()));
      },
    );

    test('Paginated: hasMore=true triggers second page fetch', () async {
      final firstPageWord = remoteDto(
        id: 'word-1',
        wordText: 'page1',
        totalCount: 1,
        isKnown: false,
        lastUpdated: DateTime.utc(2025, 1, 1, 1),
        serverTimestamp: DateTime.utc(2025, 1, 1, 1),
      );
      final secondPageWord = remoteDto(
        id: 'word-2',
        wordText: 'page2',
        totalCount: 1,
        isKnown: false,
        lastUpdated: DateTime.utc(2025, 1, 1, 2),
        serverTimestamp: DateTime.utc(2025, 1, 1, 2),
      );

      when(
        () => mockPreferences.getLastPullTimestamp(userId),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemote.fetchUserWords(
          userId,
          limit: 500,
          cursorTime: null,
          cursorId: null,
        ),
      ).thenAnswer(
        (_) async => Right(
          PaginatedSyncResult(
            words: [firstPageWord],
            nextCursorTime: firstPageWord.lastUpdated.toUtc().toIso8601String(),
            nextCursorId: firstPageWord.id,
          ),
        ),
      );
      when(
        () => mockRemote.fetchUserWords(
          userId,
          limit: 500,
          cursorTime: firstPageWord.lastUpdated.toUtc().toIso8601String(),
          cursorId: firstPageWord.id,
        ),
      ).thenAnswer(
        (_) async => Right(PaginatedSyncResult(words: [secondPageWord])),
      );
      when(
        () => mockLocal.getWordsByIds(['word-1']),
      ).thenAnswer((_) async => {});
      when(
        () => mockLocal.getWordsByIds(['word-2']),
      ).thenAnswer((_) async => {});
      when(
        () => mockLocal.saveWordsInTransaction(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockPreferences.setLastPullTimestamp(userId, any()),
      ).thenAnswer((_) async {});

      final result = await repo.pullRemoteChanges(userId);

      expect(result, const Right<Failure, int>(2));
      verify(
        () => mockRemote.fetchUserWords(
          userId,
          limit: 500,
          cursorTime: firstPageWord.lastUpdated.toUtc().toIso8601String(),
          cursorId: firstPageWord.id,
        ),
      ).called(1);
      verify(() => mockLocal.saveWordsInTransaction(any())).called(2);
    });
  });
}
