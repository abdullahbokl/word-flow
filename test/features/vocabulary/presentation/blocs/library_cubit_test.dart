import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/delete_word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/update_word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_words.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_state.dart';
import 'package:word_flow/core/usecases/usecase.dart';

import '../../../../helpers/mock_data.dart';

class MockWatchWords extends Mock implements WatchWords {}

class MockUpdateWord extends Mock implements UpdateWord {}

class MockDeleteWord extends Mock implements DeleteWord {}

class FakeUserIdParams extends Fake implements UserIdParams {}
class FakeDeleteWordParams extends Fake implements DeleteWordParams {}

void main() {
  late MockWatchWords mockWatchWords;
  late MockUpdateWord mockUpdateWord;
  late MockDeleteWord mockDeleteWord;

  setUpAll(() {
    registerFallbackValue(testWord);
    registerFallbackValue(testKnownWord);
    registerFallbackValue(FakeUserIdParams());
    registerFallbackValue(FakeDeleteWordParams());
  });

  setUp(() {
    mockWatchWords = MockWatchWords();
    mockUpdateWord = MockUpdateWord();
    mockDeleteWord = MockDeleteWord();
  });

  LibraryCubit buildCubit() => LibraryCubit(
        mockWatchWords,
        mockUpdateWord,
        mockDeleteWord,
      );

  group('LibraryCubit initial state', () {
    test('initial state is correct', () {
      final cubit = buildCubit();
      expect(cubit.state, const LibraryState.initial());
      cubit.close();
    });
  });

  group('init - watches words stream', () {
    blocTest<LibraryCubit, LibraryState>(
      'emits loading then loaded with words from stream',
      build: () {
        when(() => mockWatchWords(any()))
            .thenAnswer((_) => Stream.value(Right(testWordList)));
        return buildCubit();
      },
      act: (cubit) => cubit.init('user-1'),
      expect: () => [
        const LibraryState.loading(),
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.length == testWordList.length,
          orElse: () => false,
        )),
      ],
      verify: (cubit) {
        verify(() => mockWatchWords(const UserIdParams(userId: 'user-1'))).called(1);
      },
    );

    blocTest<LibraryCubit, LibraryState>(
      'emits multiple loaded states when stream emits multiple times',
      build: () {
        when(() => mockWatchWords(any()))
            .thenAnswer((_) => Stream.fromIterable([
          Right([testWord]),
          Right(testWordList),
        ]));
        return buildCubit();
      },
      act: (cubit) => cubit.init('user-1'),
      expect: () => [
        const LibraryState.loading(),
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.length == 1,
          orElse: () => false,
        )),
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.length == 3,
          orElse: () => false,
        )),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'accepts null userId and watches all words',
      build: () {
        when(() => mockWatchWords(any()))
            .thenAnswer((_) => Stream.value(Right(testWordList)));
        return buildCubit();
      },
      act: (cubit) => cubit.init(null),
      verify: (cubit) {
        verify(() => mockWatchWords(const UserIdParams())).called(1);
      },
    );
  });

  group('setFilter', () {
    blocTest<LibraryCubit, LibraryState>(
      'updates filter in loaded state',
      build: () {
        when(() => mockWatchWords(any()))
            .thenAnswer((_) => Stream.value(Right(testWordList)));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: testWordList),
      act: (cubit) => cubit.setFilter(WordsFilter.known),
      expect: () => [
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.filter == WordsFilter.known,
          orElse: () => false,
        )),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'ignores filter change if not in loaded state',
      build: () => buildCubit(),
      seed: () => const LibraryState.initial(),
      act: (cubit) => cubit.setFilter(WordsFilter.known),
      expect: () => [],
    );
  });

  group('setSearch', () {
    blocTest<LibraryCubit, LibraryState>(
      'updates search query in loaded state',
      build: () => buildCubit(),
      seed: () => LibraryState.loaded(words: testWordList),
      act: (cubit) => cubit.setSearch('flutter'),
      expect: () => [
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.searchQuery == 'flutter',
          orElse: () => false,
        )),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'clears search query when empty string',
      build: () => buildCubit(),
      seed: () => LibraryState.loaded(
        words: testWordList,
        searchQuery: 'previous',
      ),
      act: (cubit) => cubit.setSearch(''),
      expect: () => [
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.searchQuery == '',
          orElse: () => false,
        )),
      ],
    );
  });

  group('toggleKnown - optimistic updates', () {
    blocTest<LibraryCubit, LibraryState>(
      'toggles word state optimistically and confirms on success',
      build: () {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord]),
      act: (cubit) => cubit.toggleKnown(testWord),
      expect: () => [
        // 1. Mark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.contains(testWord.id),
          orElse: () => false,
        )),
        // 2. Optimistic: word isKnown toggled
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.first.isKnown == !testWord.isKnown,
          orElse: () => false,
        )),
        // 3. Unmark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isEmpty,
          orElse: () => false,
        )),
      ],
      verify: (cubit) {
        verify(() => mockUpdateWord(any())).called(1);
      },
    );

    blocTest<LibraryCubit, LibraryState>(
      'rolls back on toggleKnown failure',
      build: () {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('Update failed')));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord]),
      act: (cubit) => cubit.toggleKnown(testWord),
      expect: () => [
        // 1. Mark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.contains(testWord.id),
          orElse: () => false,
        )),
        // 2. Optimistic: word toggled
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.first.isKnown == !testWord.isKnown,
          orElse: () => false,
        )),
        // 3. Unmark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isEmpty,
          orElse: () => false,
        )),
        // 4. Restore word
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.first.isKnown == testWord.isKnown,
          orElse: () => false,
        )),
        // 5. Emit error
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.lastError == 'Update failed',
          orElse: () => false,
        )),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'marks word as pending during toggle',
      build: () {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord]),
      act: (cubit) => cubit.toggleKnown(testWord),
      expect: () => [
        // Pending ID should be added in the first emission
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.contains(testWord.id),
          orElse: () => false,
        )),
        // Then toggled
        anything,
        // Then pending cleared
        anything,
      ],
    );
  });

  group('deleteWord - optimistic deletion', () {
    blocTest<LibraryCubit, LibraryState>(
      'removes word optimistically and confirms on success',
      build: () {
        when(() => mockDeleteWord(any()))
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord, testKnownWord]),
      act: (cubit) => cubit.deleteWord(testWord.id, userId: 'user-1'),
      expect: () => [
        // 1. Mark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.contains(testWord.id),
          orElse: () => false,
        )),
        // 2. Optimistic: word removed
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.length == 1 && l.words[0].id == testKnownWord.id,
          orElse: () => false,
        )),
        // 3. Unmark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isEmpty,
          orElse: () => false,
        )),
      ],
      verify: (cubit) {
        verify(() => mockDeleteWord(DeleteWordParams(id: testWord.id, userId: 'user-1'))).called(1);
      },
    );

    blocTest<LibraryCubit, LibraryState>(
      'restores word on deleteWord failure',
      build: () {
        when(() => mockDeleteWord(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('Delete failed')));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord, testKnownWord]),
      act: (cubit) => cubit.deleteWord(testWord.id, userId: 'user-1'),
      expect: () => [
        // 1. Mark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.contains(testWord.id),
          orElse: () => false,
        )),
        // 2. Optimistic: word removed
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.length == 1,
          orElse: () => false,
        )),
        // 3. Unmark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isEmpty,
          orElse: () => false,
        )),
        // 4. Restore word
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.length == 2,
          orElse: () => false,
        )),
        // 5. Emit error
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.lastError == 'Delete failed',
          orElse: () => false,
        )),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'ignores deleteWord if state is not loaded',
      build: () {
        when(() => mockDeleteWord(any()))
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      seed: () => const LibraryState.initial(),
      act: (cubit) => cubit.deleteWord('some-id'),
      expect: () => [],
    );

    blocTest<LibraryCubit, LibraryState>(
      'handles deleteWord with null userId',
      build: () {
        when(() => mockDeleteWord(any()))
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord]),
      act: (cubit) => cubit.deleteWord(testWord.id),
      verify: (cubit) {
        verify(() => mockDeleteWord(DeleteWordParams(id: testWord.id))).called(1);
      },
    );
  });

  group('addWord', () {
    blocTest<LibraryCubit, LibraryState>(
      'adds new word optimistically and confirms on success',
      build: () {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord]),
      act: (cubit) => cubit.addWord('flutter', true, userId: 'user-1'),
      expect: () => [
        // 1. Mark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isNotEmpty,
          orElse: () => false,
        )),
        // 2. Optimistic: new word added
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.length == 2,
          orElse: () => false,
        )),
        // 3. Unmark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isEmpty,
          orElse: () => false,
        )),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'removes word on addWord failure',
      build: () {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('Add failed')));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord]),
      act: (cubit) => cubit.addWord('flutter', true, userId: 'user-1'),
      expect: () => [
        // 1. Mark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isNotEmpty,
          orElse: () => false,
        )),
        // 2. Optimistic: word added
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.length == 2,
          orElse: () => false,
        )),
        // 3. Unmark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isEmpty,
          orElse: () => false,
        )),
        // 4. Rollback: word removed
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.length == 1,
          orElse: () => false,
        )),
        // 5. Emit error
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.lastError == 'Add failed',
          orElse: () => false,
        )),
      ],
    );
  });

  group('updateWord', () {
    blocTest<LibraryCubit, LibraryState>(
      'updates word optimistically and confirms on success',
      build: () {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord]),
      act: (cubit) =>
          cubit.updateWord(testWord, 'updated text', !testWord.isKnown),
      expect: () => [
        // 1. Mark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.contains(testWord.id),
          orElse: () => false,
        )),
        // 2. Optimistic update
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.first.wordText == 'updated text',
          orElse: () => false,
        )),
        // 3. Unmark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isEmpty,
          orElse: () => false,
        )),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'restores word on updateWord failure',
      build: () {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('Update failed')));
        return buildCubit();
      },
      seed: () => LibraryState.loaded(words: [testWord]),
      act: (cubit) =>
          cubit.updateWord(testWord, 'new text', !testWord.isKnown),
      expect: () => [
        // 1. Mark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.contains(testWord.id),
          orElse: () => false,
        )),
        // 2. Optimistic update
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.first.wordText == 'new text',
          orElse: () => false,
        )),
        // 3. Unmark pending
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.pendingWordIds.isEmpty,
          orElse: () => false,
        )),
        // 4. Restore word
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.words.first.wordText == testWord.wordText,
          orElse: () => false,
        )),
        // 5. Emit error
        predicate<LibraryState>((s) => s.maybeMap(
          loaded: (l) => l.lastError == 'Update failed',
          orElse: () => false,
        )),
      ],
    );
  });

  group('cubit closure', () {
    test('cancels word subscription on close', () {
      final cubit = buildCubit();
      when(() => mockWatchWords(any()))
          .thenAnswer((_) => Stream.value(Right(testWordList)));
      cubit.init('user-1');
      expect(cubit.isClosed, false);
      cubit.close();
      expect(cubit.isClosed, true);
    });
  });
}
