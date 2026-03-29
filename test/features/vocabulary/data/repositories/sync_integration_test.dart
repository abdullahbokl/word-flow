import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/database/write_queue.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/sync/sync_preferences.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_remote_source.dart';
import 'package:word_flow/features/vocabulary/data/repositories/sync_repository_impl.dart';
import 'package:word_flow/features/vocabulary/data/repositories/word_repository_impl.dart';
import 'package:word_flow/features/vocabulary/data/models/word_remote_dto.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';

class MockWordRemoteSource extends Mock implements WordRemoteSource {}
class MockSyncPreferences extends Mock implements SyncPreferences {}
class MockAppLogger extends Mock implements AppLogger {}

class _TestWriteQueue implements LocalWriteQueue {
  @override
  Future<void> enqueue(Future<void> Function() job) => job();

  @override
  Future<void> close() async {}

  @override
  int get pendingCount => 0;
}

void main() {
  late WordFlowDatabase db;
  late WordLocalSource localSource;
  late SyncLocalSource syncSource;
  late MockWordRemoteSource mockRemote;
  late MockSyncPreferences mockPrefs;
  late MockAppLogger mockLogger;
  late WordRepositoryImpl wordRepo;
  late SyncRepositoryImpl syncRepo;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
    registerFallbackValue(WordRemoteDto(
      id: 'fake',
      wordText: 'fake',
      lastUpdated: DateTime.now().toUtc(),
    ));
  });

  setUp(() async {
    db = WordFlowDatabase.test(NativeDatabase.memory());
    localSource = WordLocalSourceImpl(db);
    syncSource = SyncLocalSourceImpl(db);
    mockRemote = MockWordRemoteSource();
    mockPrefs = MockSyncPreferences();
    mockLogger = MockAppLogger();
    
    // Silence logger for tests unless needed
    when(() => mockLogger.syncEvent(any())).thenReturn(null);
    when(() => mockLogger.debug(any())).thenReturn(null);
    when(() => mockLogger.info(any())).thenReturn(null);
    when(() => mockLogger.warning(any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);

    wordRepo = WordRepositoryImpl(localSource, syncSource, _TestWriteQueue(), mockLogger);
    syncRepo = SyncRepositoryImpl(localSource, syncSource, mockRemote, mockPrefs, mockLogger);
  });

  tearDown(() async {
    await db.close();
  });

  final tWord1 = WordEntity(
    id: 'id-1',
    userId: 'user-1',
    wordText: 'flutter',
    totalCount: 1,
    isKnown: false,
    lastUpdated: DateTime.now().toUtc(),
  );

  final tWord2 = tWord1.copyWith(id: 'id-2', wordText: 'dart');
  final tWord3 = tWord1.copyWith(id: 'id-3', wordText: 'sqlite');

  group('Sync Integration Tests', () {
    test('1. Full sync cycle - offline then online', () async {
      // 1. Create 3 words in local DB (userId != null triggers sync enqueue)
      await wordRepo.saveWords([tWord1, tWord2, tWord3]);

      // 2. Verify: sync queue has 3 items
      final count = await db.getPendingSyncCount();
      expect(count, 3);

      // 3. Mock: remote upsert succeeds for all 3
      when(() => mockRemote.upsertWord(any())).thenAnswer((_) async => {});

      // 4. Run: syncPendingWords()
      final result = await syncRepo.syncPendingWords();

      // 5. Verify
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => -1), 3);
      
      final remainingCount = await db.getPendingSyncCount();
      expect(remainingCount, 0);
      
      verify(() => mockRemote.upsertWord(any())).called(3);
    });

    test('2. Partial sync failure with retry', () async {
      // 1. Create 2 words
      await wordRepo.saveWords([tWord1, tWord2]);

      // 2. Mock: first succeeds, second fails
      when(() => mockRemote.upsertWord(any())).thenAnswer((_) async => {});
      
      // Override for the specific failure
      // We'll use id-2 as the failure
      when(() => mockRemote.upsertWord(any(
        that: isA<WordRemoteDto>().having((d) => d.id, 'id', tWord2.id)
      ))).thenThrow(Exception('Server Error'));

      // 3. Run: syncPendingWords()
      await syncRepo.syncPendingWords();

      // 4. Verify
      final queue = await db.getSyncQueue(10);
      expect(queue.length, 1);
      expect(queue.first.wordId, tWord2.id);
      expect(queue.first.retryCount, 1);
      expect(queue.first.lastError, contains('Exception: Server Error'));
    });

    test('3. Exponential backoff - skip item that hasn\'t waited', () async {
      // 1. Create 1 word
      await wordRepo.saveWords([tWord1]);
      
      // 2. Manually set retryCount=3 (backoff = 2^3 = 8s) and updatedAt to 5s ago
      await db.customStatement(
        'UPDATE word_sync_queue SET retry_count = 3, updated_at = ? WHERE word_id = ?',
        [DateTime.now().toUtc().subtract(const Duration(seconds: 5)).toIso8601String(), tWord1.id],
      );

      // 3. Run: syncPendingWords()
      await syncRepo.syncPendingWords();

      // 4. Verify: remote NOT called
      verifyNever(() => mockRemote.upsertWord(any()));
      final count = await db.getPendingSyncCount();
      expect(count, 1); // Still in queue
    });

    test('4. Dead letter - skip item with 11 retries', () async {
      // 1. Create 1 word
      await wordRepo.saveWords([tWord1]);
      
      // 2. Manually set retryCount=11
      await db.customStatement(
        'UPDATE word_sync_queue SET retry_count = 11 WHERE word_id = ?',
        [tWord1.id],
      );

      // 3. Run: syncPendingWords()
      final result = await syncRepo.syncPendingWords();

      // 4. Verify: item removed, remote NOT called
      expect(result.getOrElse((_) => -1), 0); // successful sync count is 0 because it was just removed
      verifyNever(() => mockRemote.upsertWord(any()));
      
      final count = await db.getPendingSyncCount();
      expect(count, 0);
    });

    test('5. Delete sync', () async {
      // 1. Save then delete a word
      await wordRepo.saveWords([tWord1]);
      // Verify first it's upsert
      expect((await db.getSyncQueue(1)).first.operation, 'upsert');
      
      await wordRepo.deleteWord(tWord1.id, userId: tWord1.userId);

      // 2. Verify: sync queue has operation='delete'
      // Note: My enqueue logic handles conflict: it deletes existing different operations for same wordId
      final queue = await db.getSyncQueue(1);
      expect(queue.length, 1);
      expect(queue.first.operation, 'delete');

      // 3. Mock: remote deleteWord succeeds
      when(() => mockRemote.deleteWord(tWord1.id)).thenAnswer((_) async => {});

      // 4. Run: syncPendingWords()
      await syncRepo.syncPendingWords();

      // 5. Verify
      expect(await db.getPendingSyncCount(), 0);
      verify(() => mockRemote.deleteWord(tWord1.id)).called(1);
    });
  });
}
