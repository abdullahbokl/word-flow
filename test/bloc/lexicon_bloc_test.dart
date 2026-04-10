import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/common/state/bloc_status.dart';
import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/lexicon/domain/commands/word_commands.dart';
import 'package:lexitrack/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/add_word_manually.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/delete_word.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/get_words.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/toggle_word_status.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/update_word.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/watch_lexicon_stats.dart';
import 'package:lexitrack/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetWords extends Mock implements GetWords {}
class MockToggleWordStatus extends Mock implements ToggleWordStatus {}
class MockDeleteWord extends Mock implements DeleteWord {}
class MockAddWordManually extends Mock implements AddWordManually {}
class MockUpdateWord extends Mock implements UpdateWord {}
class MockWatchLexiconStats extends Mock implements WatchLexiconStats {}

void main() {
  late LexiconBloc bloc;
  late MockGetWords mockGetWords;
  late MockToggleWordStatus mockToggleWordStatus;
  late MockDeleteWord mockDeleteWord;
  late MockAddWordManually mockAddWordManually;
  late MockUpdateWord mockUpdateWord;
  late MockWatchLexiconStats mockWatchStats;

  final tWord = WordEntity(
    id: 1,
    text: 'test',
    frequency: 1,
    isKnown: false,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUpAll(() {
    registerFallbackValue(const LexiconQueryParams());
    registerFallbackValue(const AddWordCommand(text: ''));
    registerFallbackValue(const UpdateWordCommand(id: 1));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetWords = MockGetWords();
    mockToggleWordStatus = MockToggleWordStatus();
    mockDeleteWord = MockDeleteWord();
    mockAddWordManually = MockAddWordManually();
    mockUpdateWord = MockUpdateWord();
    mockWatchStats = MockWatchLexiconStats();

    // Default mock behavior
    when(() => mockWatchStats(any())).thenAnswer((_) => Stream.value(const Right(LexiconStats(total: 0, known: 0, unknown: 0))));

    bloc = LexiconBloc(
      getWords: mockGetWords,
      toggleWordStatus: mockToggleWordStatus,
      deleteWord: mockDeleteWord,
      addWordManually: mockAddWordManually,
      updateWord: mockUpdateWord,
      watchStats: mockWatchStats,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LexiconBloc', () {
    test('initial state is correct', () {
      expect(bloc.state, const LexiconState());
    });

    blocTest<LexiconBloc, LexiconState>(
      'emits [loading, success] when LoadLexicon succeeds',
      build: () {
        when(() => mockGetWords(any())).thenAnswer((_) => TaskEither.right([tWord]));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadLexicon()),
      expect: () => [
        const LexiconState(status: BlocStatus.loading()),
        LexiconState(
          status: BlocStatus.success(data: [tWord]),
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<LexiconBloc, LexiconState>(
      'emits [loading, failure] when LoadLexicon fails',
      build: () {
        when(() => mockGetWords(any())).thenAnswer((_) => TaskEither.left(const DatabaseFailure('error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadLexicon()),
      expect: () => [
        const LexiconState(status: BlocStatus.loading()),
        const LexiconState(status: BlocStatus.failure(error: 'error')),
      ],
    );

    blocTest<LexiconBloc, LexiconState>(
      'updates words when ToggleWordStatusEvent is added',
      build: () {
        when(() => mockToggleWordStatus(any())).thenAnswer((_) => TaskEither.right(tWord.copyWith(isKnown: true)));
        return bloc;
      },
      seed: () => LexiconState(status: BlocStatus.success(data: [tWord])),
      act: (bloc) => bloc.add(const ToggleWordStatusEvent(1)),
      expect: () => [
        LexiconState(status: BlocStatus.success(data: [tWord.copyWith(isKnown: true)])),
        // Note: The handler emits twice, once optimistically and once after completion if the result is different or confirmed.
        // In our case the optimistic update and final result are the same ID, but let's see.
      ],
      verify: (_) {
        verify(() => mockToggleWordStatus(1)).called(1);
      },
    );

    blocTest<LexiconBloc, LexiconState>(
      'removes word when DeleteWordEvent is added',
      build: () {
        when(() => mockDeleteWord(any())).thenAnswer((_) => TaskEither.right(unit));
        return bloc;
      },
      seed: () => LexiconState(status: BlocStatus.success(data: [tWord])),
      act: (bloc) => bloc.add(const DeleteWordEvent(1)),
      expect: () => [
        const LexiconState(status: BlocStatus.success(data: [])),
      ],
      verify: (_) {
        verify(() => mockDeleteWord(1)).called(1);
      },
    );

    blocTest<LexiconBloc, LexiconState>(
      'emits new state when SearchLexicon is added',
      build: () {
        when(() => mockGetWords(any())).thenAnswer((_) => TaskEither.right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchLexicon('query')),
      expect: () => [
        const LexiconState(
          status: BlocStatus.success(data: []),
          query: 'query',
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<LexiconBloc, LexiconState>(
      'updates stats when LexiconStatsUpdateReceived is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const LexiconStatsUpdateReceived(LexiconStats(total: 10, known: 5, unknown: 5))),
      expect: () => [
        const LexiconState(stats: LexiconStats(total: 10, known: 5, unknown: 5)),
      ],
    );
   group('Pagination', () {
      blocTest<LexiconBloc, LexiconState>(
        'does not load more if hasReachedMax is true',
        build: () => bloc,
        seed: () => const LexiconState(
          status: BlocStatus.success(data: []),
          hasReachedMax: true,
        ),
        act: (bloc) => bloc.add(const LoadMoreLexicon()),
        expect: () => [],
      );

      blocTest<LexiconBloc, LexiconState>(
        'loads more words correctly',
        build: () {
          when(() => mockGetWords(any())).thenAnswer((_) => TaskEither.right([tWord.copyWith(id: 2)]));
          return bloc;
        },
        seed: () => LexiconState(
          status: BlocStatus.success(data: [tWord]),
        ),
        act: (bloc) => bloc.add(const LoadMoreLexicon()),
        expect: () => [
          LexiconState(
            status: BlocStatus.success(data: [tWord, tWord.copyWith(id: 2)]),
            page: 1,
            hasReachedMax: true,
          ),
        ],
      );
    });
  });
}
