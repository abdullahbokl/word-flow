import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/database/write_queue.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/sync/sync_operation.dart';
import 'package:word_flow/features/vocabulary/data/repositories/word_repository_impl.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mock_data.dart';

/// Test implementation of LocalWriteQueue that executes jobs immediately
/// instead of queueing them for serialization
class _TestWriteQueue implements LocalWriteQueue {
  @override
  Future<void> enqueue(Future<void> Function() job) => job();

  @override
  Future<void> close() async {}

  @override
  int get pendingCount => 0;
}

void main() {
  late MockWordLocalSource mockLocal;
  late MockSyncLocalSource mockSync;
  late MockAppLogger mockLogger;
  late LocalWriteQueue writeQueue; // Use real implementation
  late WordRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(testWord);
    registerFallbackValue(testWordRow);
    registerFallbackValue(const WordsCompanion());
    registerFallbackValue(<WordsCompanion>[]);
    registerFallbackValue(<String>[]);
    registerFallbackValue(<WordRow>[]);

  });

  setUp(() {
    mockLocal = MockWordLocalSource();
    mockSync = MockSyncLocalSource();
    mockLogger = MockAppLogger();
    writeQueue = _TestWriteQueue(); // Real queue for testing
    repo = WordRepositoryImpl(mockLocal, mockSync, writeQueue, mockLogger);
  });

  tearDown(() {
    reset(mockLocal);
    reset(mockSync);
  });

  group('saveWords', () {
    test('should merge counts for existing words', () async {

      // Arrange: existing word with count 3
      final existingWord = WordRow(
        id: 'test-id-1',
        userId: 'user-1',
        wordText: 'flutter',
        totalCount: 3,
        isKnown: false,
        lastUpdated: DateTime(2024, 1, 1),
      );
      when(() => mockLocal.getWordsByTexts(any(), userId: 'user-1'))
          .thenAnswer((_) async => [existingWord]);

      when(() => mockLocal.saveWords(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      // Act: save word with count 2
      final newWord = testWord.copyWith(totalCount: 2);
      final result = await repo.saveWords([newWord]);

      // Assert
      expect(result.isRight(), true);
      final captured = verify(() => mockLocal.saveWords(captureAny())).captured;
      final savedCompanions = captured.first as List<WordsCompanion>;
      expect(savedCompanions.length, 1);
      expect(savedCompanions[0].wordText.value, 'flutter');
      expect(savedCompanions[0].totalCount.value, 5); // 3 + 2 merged
    });

    test('should create new entries for unknown words', () async {

      when(() => mockLocal.getWordsByTexts(any(), userId: 'user-1'))
          .thenAnswer((_) async => []);

      when(() => mockLocal.saveWords(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.saveWords([testWord]);

      expect(result.isRight(), true);
      verify(() => mockLocal.saveWords(any())).called(1);
    });

    test('should enqueue sync for authenticated users', () async {

      when(() => mockLocal.getWordsByTexts(any(), userId: 'user-1'))
          .thenAnswer((_) async => []);

      when(() => mockLocal.saveWords(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      await repo.saveWords([testWord]);

      verify(() => mockSync.enqueueSyncOperation(
            testWord.id,
            SyncOperation.upsert.value,
          )).called(1);
    });

    test('should NOT enqueue sync for guest users', () async {

      when(() => mockLocal.getWordsByTexts(any(), userId: null))
          .thenAnswer((_) async => []);

      when(() => mockLocal.saveWords(any())).thenAnswer((_) async {});

      await repo.saveWords([testGuestWord]);

      verifyNever(() => mockSync.enqueueSyncOperation(any(), any()));
    });

    test('should handle multiple words batching', () async {

      when(() => mockLocal.getWordsByTexts(any(), userId: 'user-1'))
          .thenAnswer((_) async => []);

      when(() => mockLocal.saveWords(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.saveWords([testWord, testWord2]);

      expect(result.isRight(), true);
      final captured = verify(() => mockLocal.saveWords(captureAny())).captured;
      final savedCompanions = captured.first as List<WordsCompanion>;
      expect(savedCompanions.length, 2);
    });

    test('should return DatabaseFailure on error', () async {

      when(() => mockLocal.getWordsByTexts(any(), userId: any(named: 'userId')))
          .thenThrow(Exception('DB Error'));


      final result = await repo.saveWords([testWord]);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Expected left'),
      );
    });
  });

  group('toggleKnown', () {
    test('should toggle isKnown flag via local source', () async {

      final unknownWord = WordRow(
        id: 'test-id-1',
        userId: 'user-1',
        wordText: 'flutter',
        totalCount: 5,
        isKnown: false,
        lastUpdated: DateTime(2024, 1, 1),
      );
      when(() => mockLocal.getWordByText('flutter', userId: 'user-1'))
          .thenAnswer((_) async => unknownWord);
      when(() => mockLocal.saveWord(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.toggleKnown('flutter', userId: 'user-1');

      expect(result.isRight(), true);
      verify(() => mockLocal.saveWord(any())).called(1);
    });

    test('should create new word if not found', () async {

      when(() => mockLocal.getWordByText('new-word', userId: 'user-1'))
          .thenAnswer((_) async => null);
      when(() => mockLocal.saveWord(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.toggleKnown('new-word', userId: 'user-1');

      expect(result.isRight(), true);
      final captured = verify(() => mockLocal.saveWord(captureAny())).captured;
      final savedWord = captured.first as WordsCompanion;
      expect(savedWord.wordText.value, 'new-word');
      expect(savedWord.isKnown.value, true);
      expect(savedWord.totalCount.value, 1);
    });

    test('should enqueue sync for authenticated users', () async {

      when(() => mockLocal.getWordByText('flutter', userId: 'user-1'))
          .thenAnswer((_) async => testWordRow);
      when(() => mockLocal.saveWord(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      await repo.toggleKnown('flutter', userId: 'user-1');

      verify(() => mockSync.enqueueSyncOperation(any(), any())).called(1);
    });

    test('should NOT enqueue sync for guest users', () async {

      when(() => mockLocal.getWordByText('hello', userId: null))
          .thenAnswer((_) async => testGuestWordRow);
      when(() => mockLocal.saveWord(any())).thenAnswer((_) async {});

      await repo.toggleKnown('hello', userId: null);

      verifyNever(() => mockSync.enqueueSyncOperation(any(), any()));
    });

    test('should return DatabaseFailure on error', () async {

      when(() => mockLocal.getWordByText(any(), userId: any(named: 'userId')))
          .thenThrow(Exception('DB Error'));

      final result = await repo.toggleKnown('flutter', userId: 'user-1');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Expected left'),
      );
    });
  });

  group('updateWord', () {
    test('should update word in local source', () async {

      when(() => mockLocal.saveWord(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.updateWord(testWord);

      expect(result.isRight(), true);
      verify(() => mockLocal.saveWord(any())).called(1);
    });

    test('should enqueue sync for authenticated users', () async {

      when(() => mockLocal.saveWord(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      await repo.updateWord(testWord);

      verify(() => mockSync.enqueueSyncOperation(
            testWord.id,
            SyncOperation.upsert.value,
          )).called(1);
    });

    test('should NOT enqueue sync for guest users', () async {

      when(() => mockLocal.saveWord(any())).thenAnswer((_) async {});

      await repo.updateWord(testGuestWord);

      verifyNever(() => mockSync.enqueueSyncOperation(any(), any()));
    });
  });

  group('deleteWord', () {
    test('should delete word from local source', () async {

      when(() => mockLocal.deleteWord(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.deleteWord('test-id-1', userId: 'user-1');

      expect(result.isRight(), true);
      verify(() => mockLocal.deleteWord('test-id-1')).called(1);
    });

    test('should enqueue delete sync for authenticated users', () async {

      when(() => mockLocal.deleteWord(any())).thenAnswer((_) async {});
      when(() => mockSync.enqueueSyncOperation(any(), any()))
          .thenAnswer((_) async {});

      await repo.deleteWord('test-id-1', userId: 'user-1');

      verify(() => mockSync.enqueueSyncOperation(
            'test-id-1',
            SyncOperation.delete.value,
          )).called(1);
    });

    test('should NOT enqueue sync for guest users', () async {

      when(() => mockLocal.deleteWord(any())).thenAnswer((_) async {});

      await repo.deleteWord('test-id-1', userId: null);

      verifyNever(() => mockSync.enqueueSyncOperation(any(), any()));
    });

    test('should return DatabaseFailure on error', () async {

      when(() => mockLocal.deleteWord(any())).thenThrow(Exception('DB Error'));

      final result = await repo.deleteWord('test-id-1', userId: 'user-1');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Expected left'),
      );
    });
  });

  group('getKnownWordTexts', () {
    test('should return list of known word texts', () async {
      when(() => mockLocal.getKnownWordTexts(userId: 'user-1'))
          .thenAnswer((_) async => ['flutter', 'dart']);

      final result = await repo.getKnownWordTexts(userId: 'user-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (texts) => expect(texts, ['flutter', 'dart']),
      );
    });

    test('should return empty list when no known words', () async {
      when(() => mockLocal.getKnownWordTexts(userId: 'user-1'))
          .thenAnswer((_) async => []);

      final result = await repo.getKnownWordTexts(userId: 'user-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (texts) => expect(texts, isEmpty),
      );
    });

    test('should return DatabaseFailure on error', () async {
      when(() => mockLocal.getKnownWordTexts(userId: any(named: 'userId')))
          .thenThrow(Exception('DB Error'));

      final result = await repo.getKnownWordTexts(userId: 'user-1');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Expected left'),
      );
    });
  });

  group('getKnownWords', () {
    test('should return known words only', () async {
      when(() => mockLocal.getWords(userId: 'user-1'))
          .thenAnswer((_) async => [testWordRow, testKnownWordRow]);

      final result = await repo.getKnownWords(userId: 'user-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (words) => expect(words.length, 1), // Only known word
      );
    });

    test('should return empty list when no known words', () async {
      when(() => mockLocal.getWords(userId: 'user-1'))
          .thenAnswer((_) async => [testWordRow]); // Only unknown

      final result = await repo.getKnownWords(userId: 'user-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (words) => expect(words, isEmpty),
      );
    });
  });

  group('watchWords', () {
    test('should emit words stream from local source', () async {
      final testStream = Stream.value(testWordRowList);
      when(() => mockLocal.watchWords(userId: 'user-1')).thenAnswer((_) => testStream);

      final stream = repo.watchWords(userId: 'user-1');

      expect(stream, isA<Stream<List>>());
      await expectLater(
        stream,
        emits(predicate<List>((words) => words.length == 3)),
      );
    });
  });

  group('adoptGuestWords', () {
    test('should call local source with userId', () async {
      when(() => mockLocal.adoptGuestWords('user-1'))
          .thenAnswer((_) async => 5);

      final result = await repo.adoptGuestWords('user-1');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (count) => expect(count, 5),
      );
    });
  });

  group('clearLocalWords', () {
    test('should clear words for specified user', () async {
      when(() => mockLocal.clearLocalWords('user-1'))
          .thenAnswer((_) async {});

      final result = await repo.clearLocalWords('user-1');

      expect(result.isRight(), true);
      verify(() => mockLocal.clearLocalWords('user-1')).called(1);
    });

    test('should clear guest words explicitly', () async {
      when(() => mockLocal.clearGuestWords()).thenAnswer((_) async {});

      final result = await repo.clearGuestWords();

      expect(result.isRight(), true);
      verify(() => mockLocal.clearGuestWords()).called(1);
    });
  });

  group('getGuestWordsCount', () {
    test('should return count of guest words', () async {
      when(() => mockLocal.getGuestWordsCount()).thenAnswer((_) async => 10);

      final result = await repo.getGuestWordsCount();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected right'),
        (count) => expect(count, 10),
      );
    });
  });
}
