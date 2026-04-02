import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_words_paginated.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/update_word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/delete_word.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_state.dart';

class MockWatchWordsPaginated extends Mock implements WatchWordsPaginated {}

class MockUpdateWord extends Mock implements UpdateWord {}

class MockDeleteWord extends Mock implements DeleteWord {}

void main() {
  late LibraryCubit cubit;
  late MockWatchWordsPaginated mockWatchWordsPaginated;
  late MockUpdateWord mockUpdateWord;
  late MockDeleteWord mockDeleteWord;

  setUp(() {
    mockWatchWordsPaginated = MockWatchWordsPaginated();
    mockUpdateWord = MockUpdateWord();
    mockDeleteWord = MockDeleteWord();

    cubit = LibraryCubit(
      mockWatchWordsPaginated,
      mockUpdateWord,
      mockDeleteWord,
    );

    registerFallbackValue(const DeleteWordParams(id: '1', userId: null));
    registerFallbackValue(
      WordEntity(
        id: '1',
        wordText: 'test',
        isKnown: false,
        lastUpdated: DateTime.now(),
      ),
    );
    registerFallbackValue(
      const WatchWordsPaginatedParams(userId: null, limit: 50, offset: 0),
    );
  });

  const tUserId = 'user-123';
  final tWord = WordEntity(
    id: '1',
    wordText: 'hello',
    isKnown: false,
    lastUpdated: DateTime.now().toUtc(),
    userId: tUserId,
  );
  final tWords = [tWord];

  group('LibraryCubit Initial/Stream', () {
    blocTest<LibraryCubit, LibraryState>(
      'should emit loading then loaded when stream emits words',
      build: () {
        when(
          () => mockWatchWordsPaginated(any()),
        ).thenAnswer((_) => Stream.value(Right(tWords)));
        return cubit;
      },
      act: (cubit) => cubit.init(tUserId),
      expect: () => [
        const LibraryState.loading(),
        isA<LibraryState>().having(
          (s) =>
              s.maybeMap(loaded: (l) => l.words, orElse: () => <WordEntity>[]),
          'words',
          tWords,
        ),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'should emit hasMore=false when page is smaller than limit',
      build: () {
        when(
          () => mockWatchWordsPaginated(any()),
        ).thenAnswer((_) => Stream.value(Right(tWords)));
        return cubit;
      },
      act: (cubit) => cubit.init(tUserId),
      expect: () => [
        const LibraryState.loading(),
        isA<LibraryState>().having(
          (s) => s.maybeMap(loaded: (l) => l.hasMore, orElse: () => true),
          'hasMore',
          false,
        ),
      ],
    );
  });

  group('Optimistic Updates - toggleKnown', () {
    blocTest<LibraryCubit, LibraryState>(
      'should emit optimistic update (flipped isKnown) and pending status immediately',
      build: () {
        when(
          () => mockUpdateWord(any()),
        ).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.toggleKnown(tWord),
      expect: () => [
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.pendingWordIds.contains(tWord.id),
            orElse: () => false,
          ),
          'pending',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.words.first.isKnown,
            orElse: () => false,
          ),
          'flipped',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.pendingWordIds.isEmpty,
            orElse: () => false,
          ),
          'unpending',
          true,
        ),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'should rollback isKnown and emit error message when update fails',
      build: () {
        when(
          () => mockUpdateWord(any()),
        ).thenAnswer((_) async => const Left(DatabaseFailure('update error')));
        return cubit;
      },
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.toggleKnown(tWord),
      expect: () => [
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.pendingWordIds.contains(tWord.id),
            orElse: () => false,
          ),
          'pending',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.words.first.isKnown,
            orElse: () => false,
          ),
          'flipped',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.pendingWordIds.isEmpty,
            orElse: () => false,
          ),
          'unpending',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.words.first.isKnown == false,
            orElse: () => false,
          ),
          'rolled back',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.lastError == 'update error',
            orElse: () => false,
          ),
          'error',
          true,
        ),
      ],
    );
  });

  group('Optimistic Updates - deleteWord', () {
    blocTest<LibraryCubit, LibraryState>(
      'should optimistically remove word then unmark pending',
      build: () {
        when(
          () => mockDeleteWord(any()),
        ).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.deleteWord(tWord.id, userId: tUserId),
      expect: () => [
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.pendingWordIds.contains(tWord.id),
            orElse: () => false,
          ),
          'pending',
          true,
        ),
        isA<LibraryState>().having(
          (s) =>
              s.maybeMap(loaded: (l) => l.words.isEmpty, orElse: () => false),
          'removed',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.pendingWordIds.isEmpty,
            orElse: () => false,
          ),
          'unpending',
          true,
        ),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'should restore word on delete failure',
      build: () {
        when(
          () => mockDeleteWord(any()),
        ).thenAnswer((_) async => const Left(DatabaseFailure('delete error')));
        return cubit;
      },
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.deleteWord(tWord.id, userId: tUserId),
      expect: () => [
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.pendingWordIds.contains(tWord.id),
            orElse: () => false,
          ),
          'pending',
          true,
        ),
        isA<LibraryState>().having(
          (s) =>
              s.maybeMap(loaded: (l) => l.words.isEmpty, orElse: () => false),
          'removed',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.pendingWordIds.isEmpty,
            orElse: () => false,
          ),
          'unpending',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.words.contains(tWord),
            orElse: () => false,
          ),
          'restored',
          true,
        ),
        isA<LibraryState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.lastError == 'delete error',
            orElse: () => false,
          ),
          'error',
          true,
        ),
      ],
    );
  });

  group('Filter and Search', () {
    blocTest<LibraryCubit, LibraryState>(
      'should reset pagination when filter changes',
      build: () {
        when(
          () => mockWatchWordsPaginated(any()),
        ).thenAnswer((_) => Stream.value(Right(tWords)));
        return cubit;
      },
      seed: () => LibraryState.loaded(
        words: tWords,
        filter: WordsFilter.all,
        pendingWordIds: {},
      ),
      act: (cubit) {
        cubit.init(tUserId);
        cubit.setFilter(WordsFilter.known);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const LibraryState.loading(),
        predicate<LibraryState>(
          (s) => s.maybeMap(
            loaded: (l) => l.filter == WordsFilter.known,
            orElse: () => false,
          ),
          'filter is known',
        ),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'should reset pagination when search changes',
      build: () {
        when(
          () => mockWatchWordsPaginated(any()),
        ).thenAnswer((_) => Stream.value(Right(tWords)));
        return cubit;
      },
      seed: () => LibraryState.loaded(
        words: tWords,
        searchQuery: '',
        pendingWordIds: {},
      ),
      act: (cubit) {
        cubit.init(tUserId);
        cubit.setSearch('hello');
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const LibraryState.loading(),
        predicate<LibraryState>(
          (s) => s.maybeMap(
            loaded: (l) => l.searchQuery == 'hello',
            orElse: () => false,
          ),
          'searchQuery is hello',
        ),
      ],
    );
  });
}
