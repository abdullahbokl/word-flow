import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_sort.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_preferences.dart';
import 'package:wordflow/features/lexicon/domain/usecases/add_word_manually.dart';
import 'package:wordflow/features/lexicon/domain/usecases/delete_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/get_words.dart';
import 'package:wordflow/features/lexicon/domain/usecases/restore_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/toggle_word_status.dart';
import 'package:wordflow/features/lexicon/domain/usecases/update_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/watch_lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/usecases/watch_words.dart';
import 'package:wordflow/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';

class MockGetWords extends Mock implements GetWords {}

class MockWatchWords extends Mock implements WatchWords {}

class MockToggleWordStatus extends Mock implements ToggleWordStatus {}

class MockDeleteWord extends Mock implements DeleteWord {}

class MockAddWordManually extends Mock implements AddWordManually {}

class MockUpdateWord extends Mock implements UpdateWord {}

class MockWatchLexiconStats extends Mock implements WatchLexiconStats {}

class MockLexiconPreferences extends Mock implements LexiconPreferences {}

class MockRestoreWord extends Mock implements RestoreWord {}

class FakeLexiconQueryParams extends Fake implements LexiconQueryParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLexiconQueryParams());
    registerFallbackValue(const NoParams());
    registerFallbackValue(WordFilter.all);
    registerFallbackValue(WordSort.recent);
  });

  late LexiconBloc bloc;
  late MockGetWords mockGetWords;
  late MockWatchWords mockWatchWords;
  late MockToggleWordStatus mockToggleWordStatus;
  late MockDeleteWord mockDeleteWord;
  late MockAddWordManually mockAddWordManually;
  late MockUpdateWord mockUpdateWord;
  late MockWatchLexiconStats mockWatchStats;
  late MockLexiconPreferences mockCache;
  late MockRestoreWord mockRestoreWord;

  setUp(() {
    mockGetWords = MockGetWords();
    mockWatchWords = MockWatchWords();
    mockToggleWordStatus = MockToggleWordStatus();
    mockDeleteWord = MockDeleteWord();
    mockAddWordManually = MockAddWordManually();
    mockUpdateWord = MockUpdateWord();
    mockWatchStats = MockWatchLexiconStats();
    mockCache = MockLexiconPreferences();
    mockRestoreWord = MockRestoreWord();

    when(() => mockCache.getFilter()).thenReturn(WordFilter.all);
    when(() => mockCache.getSort()).thenReturn(WordSort.recent);

    bloc = LexiconBloc(
      getWords: mockGetWords,
      watchWords: mockWatchWords,
      toggleWordStatus: mockToggleWordStatus,
      deleteWord: mockDeleteWord,
      addWordManually: mockAddWordManually,
      updateWord: mockUpdateWord,
      watchStats: mockWatchStats,
      cache: mockCache,
      restoreWord: mockRestoreWord,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('LexiconBloc', () {
    final testWords = [
      WordEntity(
        id: 1,
        text: 'test',
        frequency: 1,
        isKnown: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isExcluded: false,
      ),
    ];

    const testStats = LexiconStats(
      total: 1,
      known: 0,
      unknown: 1,
    );

    blocTest<LexiconBloc, LexiconState>(
      'LoadLexicon starts watching words and stats',
      build: () {
        when(() => mockWatchWords(any()))
            .thenAnswer((_) => Stream.value(Right(testWords)));
        when(() => mockWatchStats(any()))
            .thenAnswer((_) => Stream.value(const Right(testStats)));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadLexicon()),
      expect: () => [
        isA<LexiconState>()
            .having((s) => s.status.isLoading, 'isLoading', true),
        isA<LexiconState>()
            .having((s) => s.status.isSuccess, 'isSuccess', true)
            .having((s) => s.status.data, 'data', testWords),
        isA<LexiconState>()
            .having((s) => s.status.isSuccess, 'isSuccess', true)
            .having((s) => s.status.data, 'data', testWords)
            .having((s) => s.stats, 'stats', testStats),
      ],
      verify: (_) {
        verify(() => mockWatchWords(any())).called(1);
        verify(() => mockWatchStats(any())).called(1);
      },
    );

    blocTest<LexiconBloc, LexiconState>(
      'LexiconUpdateReceived updates state with new words',
      build: () => bloc,
      act: (bloc) => bloc.add(LexiconEvent.updateReceived(words: testWords)),
      expect: () => [
        isA<LexiconState>()
            .having((s) => s.status.isSuccess, 'isSuccess', true)
            .having((s) => s.status.data, 'data', testWords),
      ],
    );

    blocTest<LexiconBloc, LexiconState>(
      'SearchLexicon updates filter and triggers reload',
      build: () {
        when(() => mockCache.saveFilter(any())).thenAnswer((_) async {});
        when(() => mockWatchWords(any()))
            .thenAnswer((_) => Stream.value(const Right([])));
        when(() => mockWatchStats(any()))
            .thenAnswer((_) => Stream.value(const Right(testStats)));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchLexicon('query')),
      wait: const Duration(milliseconds: 400), // Debounce
      expect: () => [
        isA<LexiconState>()
            .having((s) => s.query, 'query', 'query')
            .having((s) => s.status.isLoading, 'isLoading', true),
        isA<LexiconState>()
            .having((s) => s.status.isSuccess, 'isSuccess', true)
            .having((s) => s.status.data, 'data', []),
      ],
    );
  });
}
