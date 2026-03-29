import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/update_word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/delete_word.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_state.dart';

class MockWatchWords extends Mock implements WatchWords {}
class MockUpdateWord extends Mock implements UpdateWord {}
class MockDeleteWord extends Mock implements DeleteWord {}

void main() {
  late LibraryCubit cubit;
  late MockWatchWords mockWatchWords;
  late MockUpdateWord mockUpdateWord;
  late MockDeleteWord mockDeleteWord;

  setUp(() {
    mockWatchWords = MockWatchWords();
    mockUpdateWord = MockUpdateWord();
    mockDeleteWord = MockDeleteWord();
    
    cubit = LibraryCubit(
      mockWatchWords,
      mockUpdateWord,
      mockDeleteWord,
    );
    
    registerFallbackValue(DeleteWordParams(id: '1', userId: null));
    registerFallbackValue(WordEntity(
      id: '1', 
      wordText: 'test', 
      isKnown: false, 
      lastUpdated: DateTime.now()
    ));
    registerFallbackValue(UserIdParams());
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
        when(() => mockWatchWords(any()))
            .thenAnswer((_) => Stream.value(Right(tWords)));
        return cubit;
      },
      act: (cubit) => cubit.init(tUserId),
      expect: () => [
        const LibraryState.loading(),
        LibraryState.loaded(words: tWords, pendingWordIds: {}),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'should update loaded words when stream emits new data',
      build: () {
        when(() => mockWatchWords(any()))
            .thenAnswer((_) => Stream.fromIterable([
                  Right(tWords),
                  Right([tWord.copyWith(wordText: 'updated')]),
                ]));
        return cubit;
      },
      act: (cubit) => cubit.init(tUserId),
      expect: () => [
        const LibraryState.loading(),
        LibraryState.loaded(words: tWords, pendingWordIds: {}),
        LibraryState.loaded(words: [tWord.copyWith(wordText: 'updated')], pendingWordIds: {}),
      ],
    );
  });

  group('Optimistic Updates - toggleKnown', () {
    blocTest<LibraryCubit, LibraryState>(
      'should emit optimistic update (flipped isKnown) and pending status immediately',
      build: () {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) async => const Right(null));
        return cubit;
      },
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.toggleKnown(tWord),
      expect: () => [
        // 1. Mark pending
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.pendingWordIds.contains(tWord.id), orElse: () => false), 'pending', true),
        // 2. Optimistic flip
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.words.first.isKnown, orElse: () => false), 'flipped', true),
        // 3. Unmark pending
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.pendingWordIds.isEmpty, orElse: () => false), 'unpending', true),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'should rollback isKnown and emit error message when update fails',
      build: () {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('update error')));
        return cubit;
      },
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.toggleKnown(tWord),
      expect: () => [
        // 1. Mark pending
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.pendingWordIds.contains(tWord.id), orElse: () => false), 'pending', true),
        // 2. Optimistic flip
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.words.first.isKnown, orElse: () => false), 'flipped', true),
        // 3. Unmark pending
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.pendingWordIds.isEmpty, orElse: () => false), 'unpending', true),
        // 4. Rollback
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.words.first.isKnown == false, orElse: () => false), 'rolled back', true),
        // 5. Error
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.lastError == 'update error', orElse: () => false), 'error', true),
      ],
    );
  });

  group('Optimistic Updates - deleteWord', () {
    blocTest<LibraryCubit, LibraryState>(
      'should optimistically remove word then unmark pending',
      build: () {
        when(() => mockDeleteWord(any()))
            .thenAnswer((_) async => const Right(null));
        return cubit;
      },
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.deleteWord(tWord.id, userId: tUserId),
      expect: () => [
        // 1. Mark pending
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.pendingWordIds.contains(tWord.id), orElse: () => false), 'pending', true),
        // 2. Remove
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.words.isEmpty, orElse: () => false), 'removed', true),
        // 3. Unmark pending
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.pendingWordIds.isEmpty, orElse: () => false), 'unpending', true),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'should restore word on delete failure',
      build: () {
        when(() => mockDeleteWord(any()))
            .thenAnswer((_) async => const Left(DatabaseFailure('delete error')));
        return cubit;
      },
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.deleteWord(tWord.id, userId: tUserId),
      expect: () => [
        // 1. Mark pending
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.pendingWordIds.contains(tWord.id), orElse: () => false), 'pending', true),
        // 2. Temp removal
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.words.isEmpty, orElse: () => false), 'removed', true),
        // 3. Unmark pending
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.pendingWordIds.isEmpty, orElse: () => false), 'unpending', true),
        // 4. Restoration
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.words.contains(tWord), orElse: () => false), 'restored', true),
        // 5. Error
        isA<LibraryState>().having((s) => s.maybeMap(loaded: (l) => l.lastError == 'delete error', orElse: () => false), 'error', true),
      ],
    );
  });

  group('Filter and Search', () {
    blocTest<LibraryCubit, LibraryState>(
      'should update filter in state',
      build: () => cubit,
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.setFilter(WordsFilter.known),
      expect: () => [
        LibraryState.loaded(words: tWords, filter: WordsFilter.known, pendingWordIds: {}),
      ],
    );

    blocTest<LibraryCubit, LibraryState>(
      'should update searchQuery in state',
      build: () => cubit,
      seed: () => LibraryState.loaded(words: tWords, pendingWordIds: {}),
      act: (cubit) => cubit.setSearch('hello'),
      expect: () => [
        LibraryState.loaded(words: tWords, searchQuery: 'hello', pendingWordIds: {}),
      ],
    );
  });
}
