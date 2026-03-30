import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/database/app_database.dart';

void main() {
  late WordFlowDatabase db;

  setUp(() {
    // Each test starts with a fresh in-memory database
    db = WordFlowDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('WordFlowDatabase - Word Operations', () {
    test('upsertWord inserts new word correctly', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWord(WordsCompanion.insert(
        id: '1',
        wordText: 'hello',
        lastUpdated: now,
        userId: const Value('user-1'),
      ));

      final word = await db.getWordById('1');
      expect(word?.wordText, 'hello');
      expect(word?.userId, 'user-1');
    });

    test('upsertWord updates existing word on conflict (same id)', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWord(WordsCompanion.insert(
        id: '1',
        wordText: 'hello',
        lastUpdated: now,
      ));

      await db.upsertWord(WordsCompanion.insert(
        id: '1',
        wordText: 'updated',
        lastUpdated: now.add(const Duration(seconds: 1)),
      ));

      final word = await db.getWordById('1');
      expect(word?.wordText, 'updated');
    });

    test('getWordByText returns correct word for given userId', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWords([
        WordsCompanion.insert(
            id: '1', wordText: 'hello', userId: const Value('user-1'), lastUpdated: now),
        WordsCompanion.insert(
            id: '2', wordText: 'hello', userId: const Value('user-2'), lastUpdated: now),
      ]);

      final word1 = await db.getWordByText('hello', userId: 'user-1');
      final word2 = await db.getWordByText('hello', userId: 'user-2');

      expect(word1?.id, '1');
      expect(word2?.id, '2');
    });

    test('getKnownWordTexts only returns known words', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWords([
        WordsCompanion.insert(
            id: '1', wordText: 'known', isKnown: const Value(true), lastUpdated: now),
        WordsCompanion.insert(
            id: '2', wordText: 'unknown', isKnown: const Value(false), lastUpdated: now),
      ]);

      final result = await db.getKnownWordTexts();
      expect(result, contains('known'));
      expect(result.length, 1);
    });

    test('watchWords emits updates when words change', () async {
      final now = DateTime.now().toUtc();
      final stream = db.watchWords(userId: 'user-1');

      // First emission should be empty
      expect(await stream.first, isEmpty);

      // Now add a word and watch for the update
      // We expect the next list to contain our word
      final nextUpdate = stream.skip(1).first;

      await db.upsertWord(WordsCompanion.insert(
        id: '1',
        wordText: 'hello',
        userId: const Value('user-1'),
        lastUpdated: now,
      ));

      final words = await nextUpdate;
      expect(words.length, 1);
      expect(words.first.wordText, 'hello');
    });
  });

  group('WordFlowDatabase - Sync Queue', () {
    test('enqueueSyncOperation prevents duplicate entries (UNIQUE constraint)', () async {
      final now = DateTime.now().toUtc();
      // FK requirement: word must exist
      await db.upsertWord(WordsCompanion.insert(id: '1', wordText: 'hello', lastUpdated: now));

      await db.enqueueSyncOperation('1', 'upsert');
      await db.enqueueSyncOperation('1', 'upsert');

      final queue = await db.getSyncQueue(10);
      expect(queue.length, 1);
    });

    test('enqueueSyncOperation replaces cross-operations (upsert removes delete)', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWord(WordsCompanion.insert(id: '1', wordText: 'hello', lastUpdated: now));

      await db.enqueueSyncOperation('1', 'delete');
      await db.enqueueSyncOperation('1', 'upsert');

      final queue = await db.getSyncQueue(10);
      expect(queue.length, 1);
      expect(queue.first.operation, 'upsert');
    });

    test('getSyncQueue returns items in createdAt order', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWords([
        WordsCompanion.insert(id: '1', wordText: 'first', lastUpdated: now),
        WordsCompanion.insert(id: '2', wordText: 'second', lastUpdated: now),
      ]);

      await db.enqueueSyncOperation('1', 'upsert');
      // Small delay to ensure createdAt is different if DB resolution is high
      await Future.delayed(const Duration(milliseconds: 10));
      await db.enqueueSyncOperation('2', 'upsert');

      final queue = await db.getSyncQueue(10);
      expect(queue[0].wordId, '1');
      expect(queue[1].wordId, '2');
    });

    test('removeFromSyncQueue correctly removes by id', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWord(WordsCompanion.insert(id: '1', wordText: 'hello', lastUpdated: now));
      await db.enqueueSyncOperation('1', 'upsert');

      var queue = await db.getSyncQueue(10);
      final queueId = queue.first.id;

      await db.removeFromSyncQueue(queueId);
      
      queue = await db.getSyncQueue(10);
      expect(queue, isEmpty);
    });

    test('clearOrphanedSyncEntries removes entries with no matching word', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWord(WordsCompanion.insert(id: '1', wordText: 'hello', lastUpdated: now));
      await db.enqueueSyncOperation('1', 'upsert');

      // We need to bypass FK constraint to create an orphan for the test
      // or just trust that CASCADE handles it, but the method exists for robustness.
      // In SQLite we can disable foreign keys.
      await db.customStatement('PRAGMA foreign_keys = OFF;');
      await db.deleteWordById('1');
      await db.customStatement('PRAGMA foreign_keys = ON;');

      // Verify it is orphaned
      var queue = await db.getSyncQueue(10);
      expect(queue.length, 1);

      await db.clearOrphanedSyncEntries();

      queue = await db.getSyncQueue(10);
      expect(queue, isEmpty);
    });
  });

  group('WordFlowDatabase - Guest Migration', () {
    test('adoptGuestWords merges correctly (higher count, OR isKnown)', () async {
      final now = DateTime.now().toUtc();
      // Guest word duplicate
      await db.upsertWord(WordsCompanion.insert(
        id: 'guest-1',
        wordText: 'hello',
        totalCount: const Value(10),
        isKnown: const Value(false),
        lastUpdated: now,
      ));

      // User word
      await db.upsertWord(WordsCompanion.insert(
        id: 'user-1-doc',
        userId: const Value('user-1'),
        wordText: 'hello',
        totalCount: const Value(2),
        isKnown: const Value(true),
        lastUpdated: now,
      ));

      final count = await db.adoptGuestWords('user-1');
      expect(count, 1);

      final word = await db.getWordByText('hello', userId: 'user-1');
      expect(word?.totalCount, 10); // Highest
      expect(word?.isKnown, true); // Union
      
      final guestCount = await db.getGuestWordsCount();
      expect(guestCount, 0);
    });

    test('adoptGuestWords handles empty guest words gracefully', () async {
      final count = await db.adoptGuestWords('any-user');
      expect(count, 0);
    });

    test('adoptGuestWords reassigns non-conflicting guest words to userId', () async {
      final now = DateTime.now().toUtc();
      await db.upsertWord(WordsCompanion.insert(
        id: 'guest-unique',
        wordText: 'unique-to-guest',
        lastUpdated: now,
      ));

      await db.adoptGuestWords('user-1');

      final word = await db.getWordByText('unique-to-guest', userId: 'user-1');
      expect(word?.id, 'guest-unique');
      expect(word?.userId, 'user-1');
    });
  });

  test('clearLocalWords only clears words for specified userId', () async {
    final now = DateTime.now().toUtc();
    await db.upsertWords([
      WordsCompanion.insert(id: '1', wordText: 'w1', userId: const Value('u1'), lastUpdated: now),
      WordsCompanion.insert(id: '2', wordText: 'w2', userId: const Value(null), lastUpdated: now),
    ]);

    await db.clearLocalWords('u1');

    final u1Words = await db.getWordByText('w1', userId: 'u1');
    final guestWords = await db.getWordByText('w2');

    expect(u1Words, isNull);
    expect(guestWords, isNotNull);
  });

  test('clearGuestWords only clears guest words', () async {
    final now = DateTime.now().toUtc();
    await db.upsertWords([
      WordsCompanion.insert(id: '3', wordText: 'w3', userId: const Value('u2'), lastUpdated: now),
      WordsCompanion.insert(id: '4', wordText: 'w4', userId: const Value(null), lastUpdated: now),
    ]);

    await db.clearGuestWords();

    final userWord = await db.getWordByText('w3', userId: 'u2');
    final guestWord = await db.getWordByText('w4');

    expect(userWord, isNotNull);
    expect(guestWord, isNull);
  });
}
