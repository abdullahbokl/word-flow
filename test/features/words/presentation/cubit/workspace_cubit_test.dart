import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/core/utils/script_analysis.dart';
import 'package:word_flow/core/utils/script_processor.dart';
import 'package:word_flow/features/words/domain/usecases/process_script.dart';
import 'package:word_flow/features/words/domain/usecases/save_processed_words.dart';
import 'package:word_flow/features/words/domain/usecases/toggle_known_word.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_cubit.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';

class MockProcessScript extends Mock implements ProcessScript {}

class MockSaveProcessedWords extends Mock implements SaveProcessedWords {}

class MockToggleKnownWord extends Mock implements ToggleKnownWord {}

void main() {
  late MockProcessScript processScript;
  late MockSaveProcessedWords saveProcessedWords;
  late MockToggleKnownWord toggleKnownWord;

  const summary = ScriptSummary(totalWords: 4, uniqueWords: 2, newWords: 2);
  const words = [
    ProcessedWord(wordText: 'hello', totalCount: 3, isKnown: false),
    ProcessedWord(wordText: 'world', totalCount: 1, isKnown: false),
  ];

  setUp(() {
    processScript = MockProcessScript();
    saveProcessedWords = MockSaveProcessedWords();
    toggleKnownWord = MockToggleKnownWord();

    when(
      () => saveProcessedWords.call(any(), userId: any(named: 'userId')),
    ).thenAnswer((_) async => const Right(null));
  });

  WorkspaceCubit buildCubit() =>
      WorkspaceCubit(processScript, saveProcessedWords, toggleKnownWord);

  test('starts with an initial state and empty cache', () {
    final cubit = buildCubit();
    expect(cubit.state, const WorkspaceState.initial());
    expect(cubit.summary, const ScriptSummary.empty());
    expect(cubit.words, isEmpty);
    expect(cubit.pendingKnownWords, isEmpty);
    cubit.close();
  });

  blocTest<WorkspaceCubit, WorkspaceState>(
    'analyze emits processing then results and caches summary/words',
    build: () {
      when(
        () => processScript.call(any(), userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => const Right(ScriptAnalysis(summary: summary, words: words)),
      );
      when(
        () => toggleKnownWord.call(any(), userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(null));
      return buildCubit();
    },
    act: (cubit) async => cubit.analyze('hello hello hello world'),
    expect: () => [
      const WorkspaceState.processing(),
      const WorkspaceState.results(
        words: words,
        unknownWords: words,
        knownWords: [],
      ),
    ],
    verify: (cubit) {
      expect(cubit.summary, summary);
      expect(cubit.words, words);
      verify(
        () => saveProcessedWords.call(any(), userId: any(named: 'userId')),
      ).called(1);
    },
  );

  blocTest<WorkspaceCubit, WorkspaceState>(
    'analyze failure emits processing then error',
    build: () {
      when(
        () => processScript.call(any(), userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(ProcessingFailure('parse failed')));
      return buildCubit();
    },
    act: (cubit) async => cubit.analyze('broken input'),
    expect: () => [
      const WorkspaceState.processing(),
      const WorkspaceState.error('parse failed'),
    ],
  );

  blocTest<WorkspaceCubit, WorkspaceState>(
    'toggleKnown removes word after successful persistence',
    build: () {
      when(
        () => processScript.call(any(), userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => const Right(ScriptAnalysis(summary: summary, words: words)),
      );
      when(
        () => toggleKnownWord.call('hello', userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(null));
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.analyze('hello hello hello world');
      await cubit.toggleKnown('hello');
    },
    wait: const Duration(milliseconds: 340),
    expect: () => [
      const WorkspaceState.processing(),
      const WorkspaceState.results(
        words: words,
        unknownWords: words,
        knownWords: [],
      ),
      const WorkspaceState.results(
        words: [
          ProcessedWord(wordText: 'world', totalCount: 1, isKnown: false),
        ],
        unknownWords: [
          ProcessedWord(wordText: 'world', totalCount: 1, isKnown: false),
        ],
        knownWords: [],
      ),
    ],
    verify: (_) {
      verify(() => toggleKnownWord.call('hello', userId: any(named: 'userId')))
          .called(1);
    },
  );

  blocTest<WorkspaceCubit, WorkspaceState>(
    'toggleKnown failure emits error and keeps original results',
    build: () {
      when(
        () => processScript.call(any(), userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => const Right(ScriptAnalysis(summary: summary, words: words)),
      );
      when(
        () => toggleKnownWord.call('hello', userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(DatabaseFailure('update failed')));
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.analyze('hello hello hello world');
      await cubit.toggleKnown('hello');
    },
    expect: () => [
      const WorkspaceState.processing(),
      const WorkspaceState.results(
        words: words,
        unknownWords: words,
        knownWords: [],
      ),
      const WorkspaceState.error('update failed'),
      const WorkspaceState.results(
        words: words,
        unknownWords: words,
        knownWords: [],
      ),
    ],
  );
}
