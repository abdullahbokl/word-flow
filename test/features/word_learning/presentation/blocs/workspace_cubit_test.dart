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
import 'package:word_flow/features/vocabulary/domain/usecases/get_text_analysis_config.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_cubit.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_state.dart';

import 'package:word_flow/core/logging/app_logger.dart';

class MockProcessScript extends Mock implements ProcessScript {}
class MockSaveProcessedWords extends Mock implements SaveProcessedWords {}
class MockToggleKnownWord extends Mock implements ToggleKnownWord {}
class MockGetTextAnalysisConfig extends Mock implements GetTextAnalysisConfig {}
class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late WorkspaceCubit cubit;
  late MockProcessScript mockProcessScript;
  late MockSaveProcessedWords mockSaveProcessedWords;
  late MockToggleKnownWord mockToggleKnownWord;
  late MockGetTextAnalysisConfig mockGetTextAnalysisConfig;
  late MockAppLogger mockAppLogger;

  const tConfig = TextAnalysisConfig(
    stopWords: {'the', 'a'},
    language: 'english',
  );

  setUp(() {
    mockProcessScript = MockProcessScript();
    mockSaveProcessedWords = MockSaveProcessedWords();
    mockToggleKnownWord = MockToggleKnownWord();
    mockGetTextAnalysisConfig = MockGetTextAnalysisConfig();
    mockAppLogger = MockAppLogger();

    cubit = WorkspaceCubit(
      mockProcessScript,
      mockSaveProcessedWords,
      mockGetTextAnalysisConfig,
      mockToggleKnownWord,
      mockAppLogger,
    );

    registerFallbackValue(tConfig);
    registerFallbackValue(<ProcessedWord>[]);
    
    // Default mock response for config
    when(() => mockGetTextAnalysisConfig())
        .thenAnswer((_) async => const Right(tConfig));
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
        when(() => mockProcessScript(any(), userId: any(named: 'userId'), config: any(named: 'config')))
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
          config: tConfig,
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
        when(() => mockProcessScript(any(), userId: any(named: 'userId'), config: any(named: 'config')))
            .thenAnswer((_) async => const Left(ProcessingFailure('fail')));
        return cubit;
      },
      act: (cubit) => cubit.analyze('error', userId: tUserId),
      expect: () => [
        const WorkspaceState.processing(),
        const WorkspaceState.error('fail', failure: ProcessingFailure('fail')),
      ],
    );
  });
}
