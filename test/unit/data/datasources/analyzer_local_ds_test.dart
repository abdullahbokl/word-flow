import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexitrack/core/database/app_database.dart';
import 'package:lexitrack/features/text_analyzer/data/datasources/analyzer_local_ds_impl.dart';

void main() {
  late AppDatabase db;
  late AnalyzerLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase.forTesting(e: NativeDatabase.memory());
    dataSource = AnalyzerLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AnalyzerLocalDataSourceImpl', () {
    test('analyze should process text and save to database', () async {
      const title = 'Test Text';
      const content = 'Hello world, hello friends.';

      final result = await dataSource.analyze(title: title, content: content);

      expect(result.title, title);
      expect(result.totalWords, 4); // [hello, world, hello, friends]
      expect(result.uniqueWords, 3); // [hello, world, friends]
      expect(result.newWordsCount, 3);

      // Verify words were saved
      final words = await db.select(db.words).get();
      expect(words.length, 3);

      // Verify history item saved
      final history = await db.select(db.analyzedTexts).get();
      expect(history.length, 1);
      expect(history.first.title, title);

      // Verify entries linked
      final entries = await db.select(db.textWordEntries).get();
      expect(entries.length, 3);
    });

    test('analyze should reuse existing words and increment frequency',
        () async {
      // 1. First analysis
      await dataSource.analyze(title: 'T1', content: 'hello');

      final wordBefore = await (db.select(db.words)
            ..where((w) => w.word.equals('hello')))
          .getSingle();
      expect(wordBefore.frequency, 1);

      // 2. Second analysis with same word
      await dataSource.analyze(title: 'T2', content: 'hello world');

      final wordAfter = await (db.select(db.words)
            ..where((w) => w.word.equals('hello')))
          .getSingle();
      expect(wordAfter.frequency, 2);
      expect(wordAfter.word, 'hello');

      final words = await db.select(db.words).get();
      expect(words.length, 2); // hello, world
    });
  });
}
