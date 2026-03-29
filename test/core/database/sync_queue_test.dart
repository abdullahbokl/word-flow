import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/database/app_database.dart';

void main() {
  late WordFlowDatabase db;

  setUp(() {
    db = WordFlowDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Sync Queue Idempotency', () {
    test('rapid upserts produce exactly 1 queue item and update timestamp', () async {
      const wordId = 'test-word-1';
      
      await db.enqueueSyncOperation(wordId, 'upsert');
      final firstResults = await db.getSyncQueue(10);
      final firstUpdatedAt = firstResults.first.updatedAt;

      // Small delay to ensure timestamp would change if updated
      await Future.delayed(const Duration(milliseconds: 1050));

      await db.enqueueSyncOperation(wordId, 'upsert');
      
      final results = await db.getSyncQueue(10);
      expect(results, hasLength(1));
      expect(results.first.wordId, wordId);
      expect(results.first.operation, 'upsert');
      expect(results.first.updatedAt.isAfter(firstUpdatedAt), isTrue);
    });

    test('upsert followed by delete replaces the upsert', () async {
      const wordId = 'test-word-2';
      
      await db.enqueueSyncOperation(wordId, 'upsert');
      await db.enqueueSyncOperation(wordId, 'delete');

      final results = await db.getSyncQueue(10);
      expect(results, hasLength(1));
      expect(results.first.wordId, wordId);
      expect(results.first.operation, 'delete');
    });

    test('delete followed by upsert replaces the delete', () async {
      const wordId = 'test-word-3';
      
      await db.enqueueSyncOperation(wordId, 'delete');
      await db.enqueueSyncOperation(wordId, 'upsert');

      final results = await db.getSyncQueue(10);
      expect(results, hasLength(1));
      expect(results.first.wordId, wordId);
      expect(results.first.operation, 'upsert');
    });

    test('retry count resets on re-queue of existing operation type', () async {
      const wordId = 'test-word-4';
      
      // 1. Initial enqueue
      await db.enqueueSyncOperation(wordId, 'upsert');
      var results = await db.getSyncQueue(10);
      final firstRowId = results.first.id;

      // 2. Mock a failure by incrementing retry count
      await db.updateSyncQueueRetry(firstRowId, 'Mock Network Error');
      
      results = await db.getSyncQueue(10);
      expect(results.first.retryCount, 1);
      expect(results.first.lastError, 'Mock Network Error');

      // 3. Re-enqueue same word and operation
      await db.enqueueSyncOperation(wordId, 'upsert');

      results = await db.getSyncQueue(10);
      expect(results, hasLength(1));
      expect(results.first.retryCount, 0, reason: 'Retry count must reset to 0');
      expect(results.first.lastError, isNull, reason: 'Last error must be cleared');
    });

    test('distinct operations for DIFFERENT words remain independent', () async {
      await db.enqueueSyncOperation('word-A', 'upsert');
      await db.enqueueSyncOperation('word-B', 'delete');

      final results = await db.getSyncQueue(10);
      expect(results, hasLength(2));
    });
  });
}
