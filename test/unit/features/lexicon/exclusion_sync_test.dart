import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordflow/core/cache/local_cache.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_local_ds_impl.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';

import '../../../helpers/mock_database.dart';

class MockLocalCache extends Mock implements LocalCache {}

void main() {
  late LexiconLocalDataSourceImpl dataSource;
  late AppDatabase db;
  late MockLocalCache mockCache;

  setUp(() {
    db = getMockDatabase();
    mockCache = MockLocalCache();
    dataSource = LexiconLocalDataSourceImpl(db, mockCache);

    when(() => mockCache.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockCache.getString(any())).thenReturn(null);
  });

  tearDown(() async {
    await db.close();
  });

  group('Exclusion Bidirectional Sync', () {
    test('adding an excluded word makes it appear only in excluded filter',
        () async {
      await dataSource.addWord('excluded_word', isExcluded: true);
      await dataSource.addWord('active_word');

      final excludedWords =
          await dataSource.getWords(filter: WordFilter.excluded);
      final activeWords = await dataSource.getWords();

      expect(excludedWords.length, 1);
      expect(excludedWords.first.word, 'excluded_word');
      expect(activeWords.length, 1);
      expect(activeWords.first.word, 'active_word');
    });

    test('excluding an active word moves it to excluded filter', () async {
      final word = await dataSource.addWord('test_word');

      var activeWords = await dataSource.getWords();
      expect(activeWords.length, 1);

      await dataSource.excludeWord(word.id);

      activeWords = await dataSource.getWords();
      final excludedWords =
          await dataSource.getWords(filter: WordFilter.excluded);

      expect(activeWords, isEmpty);
      expect(excludedWords.length, 1);
      expect(excludedWords.first.word, 'test_word');
    });

    test('unexcluding an excluded word moves it back to active filter',
        () async {
      final word = await dataSource.addWord('test_word', isExcluded: true);

      var excludedWords =
          await dataSource.getWords(filter: WordFilter.excluded);
      expect(excludedWords.length, 1);

      await dataSource.unexcludeWord(word.id);

      excludedWords = await dataSource.getWords(filter: WordFilter.excluded);
      final activeWords = await dataSource.getWords();

      expect(excludedWords, isEmpty);
      expect(activeWords.length, 1);
      expect(activeWords.first.word, 'test_word');
    });

    test('watchWords reflects exclusion changes immediately', () async {
      final word = await dataSource.addWord('test_word');

      final activeStream = dataSource.watchWords();
      final excludedStream = dataSource.watchWords(filter: WordFilter.excluded);

      expect(activeStream,
          emits(predicate((words) => (words as List).length == 1)));
      expect(excludedStream, emits(isEmpty));

      await dataSource.excludeWord(word.id);

      expect(activeStream, emits(isEmpty));
      expect(excludedStream,
          emits(predicate((words) => (words as List).length == 1)));
    });
  });
}
