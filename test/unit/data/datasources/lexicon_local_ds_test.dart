import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordflow/core/cache/local_cache.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_local_ds_impl.dart';

class MockLocalCache extends Mock implements LocalCache {}

void main() {
  late AppDatabase db;
  late LexiconLocalDataSourceImpl dataSource;
  late MockLocalCache mockCache;

  setUp(() {
    db = AppDatabase.forTesting(e: NativeDatabase.memory());
    mockCache = MockLocalCache();
    dataSource = LexiconLocalDataSourceImpl(db, mockCache);
  });

  tearDown(() async {
    await db.close();
  });

  group('LexiconLocalDataSourceImpl', () {
    test('addWord should insert and return word', () async {
      final word = await dataSource.addWord('apple');

      expect(word.word, 'apple');
      expect(word.frequency, 0);

      final inDb = await db.select(db.words).get();
      expect(inDb.length, 1);
    });

    test('getStats should fetch from db and save to cache', () async {
      await dataSource.addWord('a');
      await dataSource.addWord('b');

      when(() => mockCache.setString(any(), any())).thenAnswer((_) async {});

      final stats = await dataSource.getStats();

      expect(stats.total, 2);
      verify(() => mockCache.setString(any(), '2:0:2')).called(1);
    });

    test('watchStats should return cached value first then db stream',
        () async {
      const cacheKey = 'lexicon_stats_cache';
      when(() => mockCache.getString(cacheKey)).thenReturn('5:2:3');
      when(() => mockCache.setString(any(), any())).thenAnswer((_) async {});

      final statsStream = dataSource.watchStats();

      final results = await statsStream.take(2).toList();

      // First is from cache
      expect(results[0].total, 5);
      // Second is from DB (empty initially)
      expect(results[1].total, 0);
    });
  });
}
