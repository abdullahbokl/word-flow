import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:drift/drift.dart';

void main() {
  late WordFlowDatabase db;

  setUp(() {
    db = WordFlowDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('adoptGuestWords() optimization', () {
    test('User with 0 existing words adopting 5 guest words enqueues exactly 5 items', () async {
      // 1. Setup 5 guest words
      for (int i = 0; i < 5; i++) {
        await db.into(db.words).insert(WordsCompanion.insert(
              id: 'guest-$i',
              wordText: 'word-$i',
              lastUpdated: DateTime.now(),
            ));
      }

      // 2. Adopt
      final adoptedCount = await db.adoptGuestWords('user-123');

      // 3. Verify
      expect(adoptedCount, 5);
      
      final syncQueueCount = await db.getPendingSyncCount();
      expect(syncQueueCount, 5);
      
      final userWords = await (db.select(db.words)..where((t) => t.userId.equals('user-123'))).get();
      expect(userWords, hasLength(5));
    });

    test('User with existing words only enqueues newly migrated or merged words', () async {
      const userId = 'user-123';
      
      // 1. Setup 3 existing user words
      for (int i = 0; i < 3; i++) {
        await db.into(db.words).insert(WordsCompanion.insert(
              id: 'user-word-$i',
              userId: const Value(userId),
              wordText: 'existing-$i',
              lastUpdated: DateTime.now(),
            ));
      }
      
      // 2. Setup 2 NEW guest words + 1 CONFLICTING guest word
      // New words
      await db.into(db.words).insert(WordsCompanion.insert(
            id: 'guest-new-1',
            wordText: 'guest-new-1',
            lastUpdated: DateTime.now(),
          ));
      await db.into(db.words).insert(WordsCompanion.insert(
            id: 'guest-new-2',
            wordText: 'guest-new-2',
            lastUpdated: DateTime.now(),
          ));
      // Conflicting word (matches 'existing-0')
      await db.into(db.words).insert(WordsCompanion.insert(
            id: 'guest-conflict',
            wordText: 'existing-0',
            totalCount: const Value(10),
            lastUpdated: DateTime.now(),
          ));

      // Clear sync queue (setup might have triggered enqueueing if repo was used, 
      // but here we use direct DB access so it's empty)
      final initialQueueCount = await db.getPendingSyncCount();
      expect(initialQueueCount, 0);

      // 3. Adopt
      final adoptedCount = await db.adoptGuestWords(userId);

      // 4. Verify
      expect(adoptedCount, 3); // 2 new + 1 conflicting
      
      // Enqueued should be: guest-new-1, guest-new-2, AND user-word-0 (merged)
      // Enqueued should NOT be: user-word-1, user-word-2 (untouched)
      final syncQueue = await db.getSyncQueue(100);
      expect(syncQueue, hasLength(3));
      
      final enqueuedIds = syncQueue.map((e) => e.wordId).toSet();
      expect(enqueuedIds, contains('guest-new-1'));
      expect(enqueuedIds, contains('guest-new-2'));
      expect(enqueuedIds, contains('user-word-0'));
      expect(enqueuedIds, isNot(contains('user-word-1')));
      expect(enqueuedIds, isNot(contains('user-word-2')));
    });
   group('adoptGuestWords() merge strategy', () {
    test('conflicting guest words update existing user word metrics', () async {
      const userId = 'user-123';
      const wordText = 'consistent';
      
      // 1. Existing user word: count 1, NOT known
      await db.into(db.words).insert(WordsCompanion.insert(
            id: 'user-id-1',
            userId: const Value(userId),
            wordText: wordText,
            totalCount: const Value(1),
            isKnown: const Value(false),
            lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
          ));

      // 2. Guest word: count 5, IS known
      await db.into(db.words).insert(WordsCompanion.insert(
            id: 'guest-id-1',
            wordText: wordText,
            totalCount: const Value(5),
            isKnown: const Value(true),
            lastUpdated: DateTime.now(),
          ));

      // 3. Adopt
      await db.adoptGuestWords(userId);

      // 4. Verify user word is updated
      final result = await (db.select(db.words)..where((t) => t.id.equals('user-id-1'))).getSingle();
      expect(result.totalCount, 5);
      expect(result.isKnown, isTrue);
      
      // 5. Verify guest word is deleted
      final guestWords = await (db.select(db.words)..where((t) => t.userId.isNull())).get();
      expect(guestWords, isEmpty);
    });
  });
  });
}
