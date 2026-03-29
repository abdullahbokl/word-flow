import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/word_learning/domain/usecases/process_script.dart';
import 'package:word_flow/features/word_learning/domain/usecases/save_processed_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/toggle_known_word.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_cubit.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_state.dart';

import 'package:word_flow/core/logging/app_logger.dart';

class MockProcessScript extends Mock implements ProcessScript {}

class MockSaveProcessedWords extends Mock implements SaveProcessedWords {}
class MockToggleKnownWord extends Mock implements ToggleKnownWord {}
class MockAppLogger extends Mock implements AppLogger {}


void main() {
  late WorkspaceCubit cubit;
  late MockProcessScript mockProcessScript;
  late MockSaveProcessedWords mockSaveProcessedWords;
  late MockToggleKnownWord mockToggleKnownWord;
  late MockAppLogger mockAppLogger;


  setUp(() {
    mockProcessScript = MockProcessScript();
    mockSaveProcessedWords = MockSaveProcessedWords();
    mockToggleKnownWord = MockToggleKnownWord();
    mockAppLogger = MockAppLogger();

    cubit = WorkspaceCubit(
      mockProcessScript,
      mockSaveProcessedWords,
      mockToggleKnownWord,
      mockAppLogger,
    );


    registerFallbackValue(<ProcessedWord>[]);
  });

  const tUserId = 'user-123';
  final tProcessedWords = [
    const ProcessedWord(wordText: 'hello', totalCount: 2, isKnown: false),
  ];
  final tAnalysis = ScriptAnalysis(
    summary: const ScriptSummary(totalWords: 2, uniqueWords: 1, newWords: 1),
    words: tProcessedWords,
  );

  group('WorkspaceCubit - Analyze', () {
    blocTest<WorkspaceCubit, WorkspaceState>(
      'should emit initial when text is empty',
      build: () => cubit,
      act: (cubit) => cubit.analyze('   '),
      expect: () => [const WorkspaceState.initial()],
    );

    blocTest<WorkspaceCubit, WorkspaceState>(
      'should emit processing then results on success',
      build: () {
        when(() => mockProcessScript(any(), userId: any(named: 'userId')))
            .thenAnswer((_) async => Right(tAnalysis));
        when(() => mockSaveProcessedWords(any(), userId: any(named: 'userId')))
            .thenAnswer((_) async => const Right(null));
        return cubit;
      },
      act: (cubit) => cubit.analyze('hello hello', userId: tUserId),
      expect: () => [
        const WorkspaceState.processing(),
        WorkspaceState.results(
          words: tProcessedWords,
          summary: tAnalysis.summary,
          pendingKnownWords: {},
          revision: 1,
        ),
      ],
      verify: (_) {
        verify(() => mockSaveProcessedWords(tProcessedWords, userId: tUserId)).called(1);
      },
    );

    blocTest<WorkspaceCubit, WorkspaceState>(
      'should emit error when process fails',
      build: () {
        when(() => mockProcessScript(any(), userId: any(named: 'userId')))
            .thenAnswer((_) async => const Left(ProcessingFailure('fail')));
        return cubit;
      },
      act: (cubit) => cubit.analyze('error', userId: tUserId),
      expect: () => [
        const WorkspaceState.processing(),
        const WorkspaceState.error('fail'),
      ],
    );
  });

  group('WorkspaceCubit - ToggleKnown (Revision Guard)', () {
    blocTest<WorkspaceCubit, WorkspaceState>(
      'should prevent double-toggle (idempotency)',
      build: () => cubit,
      seed: () => WorkspaceState.results(
        words: tProcessedWords,
        summary: tAnalysis.summary,
        pendingKnownWords: {'hello'},
        revision: 1,
      ),
      act: (cubit) => cubit.toggleKnown('hello'),
      expect: () => [], // No new state emitted
      verify: (_) {
        verifyNever(() => mockToggleKnownWord(any(), userId: any(named: 'userId')));
      },
    );

    test('toggleKnown with stale revision should NOT update UI after usecase returns', () async {
       // Manual async testing for revision-based logic since it uses unawaited/delayed
       when(() => mockToggleKnownWord(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async {
             await Future.delayed(const Duration(milliseconds: 10)); // Simulate delay
             return const Right(null);
          });
       
       // 1. Setup results with revision 1
       cubit.emit(WorkspaceState.results(
          words: tProcessedWords,
          summary: tAnalysis.summary,
          pendingKnownWords: {},
          revision: 1,
       ));

       // 2. Start toggle (this uses unawaited delay internally)
       await cubit.toggleKnown('hello');
       
       // 3. IMMEDIATELY update state to revision 2 (new analysis finished)
       cubit.emit(WorkspaceState.results(
          words: tProcessedWords,
          summary: tAnalysis.summary,
          pendingKnownWords: {},
          revision: 2,
       ));

       // 4. Wait for the toggle delay (helpers uses 280ms)
       await Future.delayed(const Duration(milliseconds: 400));

       // assert: state should STILL be the revision 2 state, and NOT updated (word removed)
       final state = cubit.state.maybeMap(results: (s) => s, orElse: () => null);
       expect(state?.revision, 2);
       expect(state?.words.length, 1); // Word NOT removed because revision changed
       expect(state?.pendingKnownWords, isEmpty);
    });
  });
}
