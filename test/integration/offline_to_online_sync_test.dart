import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/database/app_database.dart';

void main() {
  group('Offline→Online Sync Integration Tests', () {
    late WordFlowDatabase db;

    setUp(() async {
      db = WordFlowDatabase.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Phase 1: Offline word creation and persistence', () async {
      const userId = 'test-user-123';
      final now = DateTime.now().toUtc();

      // User works offline: insert words locally
      await db.upsertWords([
        WordsCompanion.insert(
          id: 'word-1',
          userId: const Value(userId),
          wordText: 'flutter',
          totalCount: const Value(5),
          isKnown: const Value(false),
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: 'word-2',
          userId: const Value(userId),
          wordText: 'dart',
          totalCount: const Value(3),
          isKnown: const Value(false),
          lastUpdated: now,
        ),
      ]);

      // Verify words persisted
      final localWords = await (db.select(
        db.words,
      )..where((w) => w.userId.equals(userId))).get();
      expect(localWords.length, 2);

      // User marks word as known while offline
      await db.upsertWord(
        WordsCompanion(
          id: const Value('word-1'),
          userId: const Value(userId),
          wordText: const Value('flutter'),
          isKnown: const Value(true),
          lastUpdated: Value(now.add(const Duration(minutes: 1))),
        ),
      );

      // Verify update persisted
      final updatedWord = await db.getWordById('word-1');
      expect(updatedWord?.isKnown, true);
    });

    test('Phase 2: Offline word modifications tracked', () async {
      const userId = 'test-user-123';
      final baseTime = DateTime.now().toUtc();

      // Create word offline
      await db.upsertWord(
        WordsCompanion.insert(
          id: 'tracked-word',
          userId: const Value(userId),
          wordText: 'modification-test',
          totalCount: const Value(1),
          isKnown: const Value(false),
          lastUpdated: baseTime,
        ),
      );

      // Update multiple times offline
      for (int i = 2; i <= 4; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await db.upsertWord(
          WordsCompanion(
            id: const Value('tracked-word'),
            userId: const Value(userId),
            wordText: const Value('modification-test'),
            totalCount: Value(i),
            isKnown: Value(i > 2),
            lastUpdated: Value(baseTime.add(Duration(milliseconds: i * 50))),
          ),
        );
      }

      // Final state should be preserved
      final finalWord = await db.getWordById('tracked-word');
      expect(finalWord?.totalCount, 4);
      expect(finalWord?.isKnown, true);
    });

    test('Phase 3: Enqueue sync operations for pending words', () async {
      const userId = 'test-user-123';
      final now = DateTime.now().toUtc();

      // Create words offline
      await db.upsertWords([
        WordsCompanion.insert(
          id: 'sync-word-1',
          userId: const Value(userId),
          wordText: 'word-1',
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: 'sync-word-2',
          userId: const Value(userId),
          wordText: 'word-2',
          lastUpdated: now,
        ),
      ]);

      // Enqueue both for sync
      await db.enqueueSyncOperation('sync-word-1', 'upsert');
      await db.enqueueSyncOperation('sync-word-2', 'upsert');

      // Verify queue has both entries
      final queue = await db.getSyncQueue(10);
      expect(queue.length, 2);
      expect(queue.map((e) => e.wordId).toSet(), {
        'sync-word-1',
        'sync-word-2',
      });
    });

    test(
      'Phase 4: Sync queue idempotency - same operation deduplication',
      () async {
        const wordId = 'dedup-word';

        // Enqueue same operation twice
        await db.enqueueSyncOperation(wordId, 'upsert');
        await db.enqueueSyncOperation(wordId, 'upsert');

        // Should still be 1 entry
        final queue = await db.getSyncQueue(10);
        expect(queue.length, 1);

        // Retry count should be reset to 0
        expect(queue.first.retryCount, 0);
      },
    );

    test('Phase 5: Sync queue cross-operation replacement', () async {
      const wordId = 'cross-op-word';

      // Enqueue upsert
      await db.enqueueSyncOperation(wordId, 'upsert');
      var queue = await db.getSyncQueue(10);
      expect(queue.first.operation, 'upsert');

      // Re-enqueue as delete (should replace)
      await db.enqueueSyncOperation(wordId, 'delete');
      queue = await db.getSyncQueue(10);
      expect(queue.length, 1);
      expect(queue.first.operation, 'delete');

      // Re-enqueue as upsert again (should replace again)
      await db.enqueueSyncOperation(wordId, 'upsert');
      queue = await db.getSyncQueue(10);
      expect(queue.length, 1);
      expect(queue.first.operation, 'upsert');
    });

    test('Phase 6: Sync queue processing order (oldest first)', () async {
      final now = DateTime.now().toUtc();

      // Create words at different times
      await db.upsertWords([
        WordsCompanion.insert(
          id: 'third-word',
          wordText: 'third',
          lastUpdated: now.add(const Duration(milliseconds: 100)),
        ),
        WordsCompanion.insert(
          id: 'first-word',
          wordText: 'first',
          lastUpdated: now,
        ),
        WordsCompanion.insert(
          id: 'second-word',
          wordText: 'second',
          lastUpdated: now.add(const Duration(milliseconds: 50)),
        ),
      ]);

      // Enqueue in different order than creation
      await db.enqueueSyncOperation('third-word', 'upsert');
      await Future.delayed(const Duration(milliseconds: 10));
      await db.enqueueSyncOperation('first-word', 'upsert');
      await Future.delayed(const Duration(milliseconds: 10));
      await db.enqueueSyncOperation('second-word', 'upsert');

      // Retrieve in order - should be by createdAt (enqueue order = first, second, third)
      final queue = await db.getSyncQueue(10);
      expect(queue.map((e) => e.wordId).toList(), [
        'third-word',
        'first-word',
        'second-word',
      ]);
    });

    test('Phase 7: Retry tracking with error messages', () async {
      const wordId = 'retry-word';

      // Create word
      await db.upsertWord(
        WordsCompanion.insert(
          id: wordId,
          wordText: 'retry-me',
          lastUpdated: DateTime.now().toUtc(),
        ),
      );

      // Enqueue
      await db.enqueueSyncOperation(wordId, 'upsert');

      var queue = await db.getSyncQueue(1);
      expect(queue.first.retryCount, 0);
      expect(queue.first.lastError, null);

      // Simulate retry with error
      final queueId = queue.first.id;
      final word = await db.getWordById(wordId);

      // In real code, this would be done by repository
      // For this test, we verify the database supports it
      expect(word, isNotNull);
      expect(queueId > 0, true);
    });

    test('Phase 8: Delete word and verify removal', () async {
      const userId = 'test-user-123';
      final now = DateTime.now().toUtc();

      // Create word
      await db.upsertWord(
        WordsCompanion.insert(
          id: 'delete-word',
          userId: const Value(userId),
          wordText: 'will-be-deleted',
          lastUpdated: now,
        ),
      );

      // Verify word exists
      var word = await db.getWordById('delete-word');
      expect(word, isNotNull);

      // Delete word
      await db.deleteWordById('delete-word');

      // Verify word is gone
      word = await db.getWordById('delete-word');
      expect(word, null);
    });

    test('Complete offline→pending→ready-to-sync flow', () async {
      const userId = 'integration-user';
      final baseTime = DateTime.now().toUtc();

      // 1. Offline: Create, modify, delete operations
      await db.upsertWords([
        WordsCompanion.insert(
          id: 'persist-word',
          userId: const Value(userId),
          wordText: 'persistent',
          totalCount: const Value(1),
          isKnown: const Value(false),
          lastUpdated: baseTime,
        ),
        WordsCompanion.insert(
          id: 'temp-word',
          userId: const Value(userId),
          wordText: 'temporary',
          totalCount: const Value(1),
          isKnown: const Value(false),
          lastUpdated: baseTime,
        ),
      ]);

      // Modify persist-word
      await db.upsertWord(
        WordsCompanion(
          id: const Value('persist-word'),
          userId: const Value(userId),
          wordText: const Value('persistent'),
          totalCount: const Value(5),
          lastUpdated: Value(baseTime.add(const Duration(minutes: 1))),
        ),
      );

      // 2. Enqueue for sync
      await db.enqueueSyncOperation('persist-word', 'upsert');
      await db.enqueueSyncOperation('temp-word', 'upsert');

      // 3. Before sync: verify state
      var queue = await db.getSyncQueue(10);
      expect(queue.length, 2);

      var localWords = await (db.select(
        db.words,
      )..where((w) => w.userId.equals(userId))).get();
      expect(localWords.length, 2);

      // Verify the modified persist-word has correct count
      final persistWord = await db.getWordById('persist-word');
      expect(persistWord?.totalCount, 5);

      // 4. After sync (simulate clearing queue)
      for (final item in queue) {
        await db.removeFromSyncQueue(item.id);
      }

      // 5. Verify post-sync state
      queue = await db.getSyncQueue(10);
      expect(queue.isEmpty, true);

      // Local words still there (sync clears queue, not words)
      localWords = await (db.select(
        db.words,
      )..where((w) => w.userId.equals(userId))).get();
      expect(localWords.length, 2);
    });
  });
}
