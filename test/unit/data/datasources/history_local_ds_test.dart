import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/history/data/datasources/history_local_ds.dart';

void main() {
  late AppDatabase db;
  late HistoryLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase.forTesting(e: NativeDatabase.memory());
    dataSource = HistoryLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('HistoryLocalDataSourceImpl', () {
    test('getHistory should return saved items', () async {
      final now = DateTime.now();
      await db.into(db.analyzedTexts).insert(
            AnalyzedTextsCompanion.insert(
              title: 'History 1',
              content: 'Content',
              totalWords: 10,
              uniqueWords: 5,
              createdAt: now,
            ),
          );

      final history = await dataSource.getHistory();
      
      expect(history.length, 1);
      expect(history.first.title, 'History 1');
    });

    test('deleteHistoryItem should remove item and optionally words', () async {
       final id = await db.into(db.analyzedTexts).insert(
            AnalyzedTextsCompanion.insert(
              title: 'To Delete',
              content: 'Content',
              totalWords: 10,
              uniqueWords: 5,
              createdAt: DateTime.now(),
            ),
          );

      await dataSource.deleteHistoryItem(id);
      
      final history = await dataSource.getHistory();
      expect(history.isEmpty, true);
    });
  });
}
