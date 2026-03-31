import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/database/app_database.dart';

void main() {
  group('adoptGuestWords migration', () {
    late WordFlowDatabase db;

    setUp(() {
      db = WordFlowDatabase.test(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('merges duplicate guest words and enqueues sync for user', () async {
      final now = DateTime.now().toUtc();

      // Arrange: guest has 'flutter' (count 5) and 'dart' (count 2)
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              id: 'g-flutter',
              userId: const Value(null),
              wordText: 'flutter',
              totalCount: const Value(5),
              isKnown: const Value(false),
              lastUpdated: now.subtract(const Duration(days: 1)),
            ),
          );

      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              id: 'g-dart',
              userId: const Value(null),
              wordText: 'dart',
              totalCount: const Value(2),
              isKnown: const Value(false),
              lastUpdated: now.subtract(const Duration(days: 1)),
            ),
          );

      // User already has 'flutter' with lower count
      await db
          .into(db.words)
          .insert(
            WordsCompanion.insert(
              id: 'u-flutter',
              userId: const Value('user-1'),
              wordText: 'flutter',
              totalCount: const Value(3),
              isKnown: const Value(false),
              lastUpdated: now.subtract(const Duration(days: 2)),
            ),
          );

      // Act
      final migrated = await db.adoptGuestWords('user-1');

      // Assert: migrated count should equal number of guest words (2)
      expect(migrated, 2);

      // Verify guest rows removed
      final guests = await (db.select(
        db.words,
      )..where((t) => t.userId.equals('GUEST'))).get();
      expect(guests, isEmpty);

      // Verify user words: 'flutter' has max count (5) and 'dart' is reassigned
      final flutter = await db.getWordByText('flutter', userId: 'user-1');
      expect(flutter, isNotNull);
      expect(flutter!.totalCount, 5);

      final dart = await db.getWordByText('dart', userId: 'user-1');
      expect(dart, isNotNull);
      expect(dart!.userId, 'user-1');

      // Verify sync queue entries exist for these words (operation == 'upsert')
      final syncEntries = await db.select(db.wordSyncQueue).get();
      final upserts = syncEntries
          .where((e) => e.operation == 'upsert')
          .toList();
      // Expect at least two upsert entries (flutter + dart)
      expect(upserts.length, greaterThanOrEqualTo(2));
      final syncedWordIds = upserts.map((e) => e.wordId).toSet();
      expect(syncedWordIds.contains(flutter.id), isTrue);
      expect(syncedWordIds.contains(dart.id), isTrue);
    });
  });
}
