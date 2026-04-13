import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_local_ds.dart';
import 'package:wordflow/features/lexicon/data/repositories/lexicon_repository_impl.dart';
import 'package:wordflow/features/lexicon/domain/commands/word_commands.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_sort.dart';
import 'package:mocktail/mocktail.dart';

class MockLexiconLocalDataSource extends Mock implements LexiconLocalDataSource {}

void main() {
  late LexiconRepositoryImpl repository;
  late MockLexiconLocalDataSource mockDataSource;

  setUpAll(() {
    registerFallbackValue(WordFilter.all);
    registerFallbackValue(WordSort.frequencyDesc);
  });

  setUp(() {
    mockDataSource = MockLexiconLocalDataSource();
    repository = LexiconRepositoryImpl(mockDataSource);
  });

  final tWordRow = WordRow(
    id: 1,
    word: 'test',
    frequency: 1,
    isKnown: false,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  group('getWords', () {
    test('should return list of words when data source succeeds', () async {
      when(() => mockDataSource.getWords(
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => [tWordRow]);

      final result = await repository.getWords().run();

      expect(result.isRight(), true);
      result.fold((_) {}, (words) => expect(words.first.text, 'test'));
    });
  });

  group('addWord', () {
    test('should call data source to add word', () async {
      when(() => mockDataSource.addWord(any())).thenAnswer((_) async => tWordRow);

      const command = AddWordCommand(text: 'new');
      final result = await repository.addWord(command).run();

      expect(result.isRight(), true);
      verify(() => mockDataSource.addWord('new')).called(1);
    });
  });

  group('updateWord', () {
    test('should call data source with command fields', () async {
      when(() => mockDataSource.updateWord(
            any(),
            text: any(named: 'text'),
            meaning: any(named: 'meaning'),
            isKnown: any(named: 'isKnown'),
            definitions: any(named: 'definitions'),
            examples: any(named: 'examples'),
            translations: any(named: 'translations'),
            synonyms: any(named: 'synonyms'),
          )).thenAnswer((_) async => tWordRow);

      const command = UpdateWordCommand(id: 1, text: 'updated', isKnown: true);
      final result = await repository.updateWord(command).run();

      expect(result.isRight(), true);
      verify(() => mockDataSource.updateWord(
            1,
            text: 'updated',
            isKnown: true,
          )).called(1);
    });
  });

  group('getStats', () {
    test('should return lexicon stats', () async {
      const tStats = LexiconStats(total: 10, known: 5, unknown: 5);
      when(() => mockDataSource.getStats()).thenAnswer((_) async => tStats);

      final result = await repository.getStats().run();

      expect(result, const Right(tStats));
    });
  });
}
