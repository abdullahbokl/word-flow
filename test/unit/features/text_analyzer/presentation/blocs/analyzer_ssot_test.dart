import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/lexicon/domain/usecases/toggle_word_status.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/analyze_text.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/update_analysis_counts.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/watch_analysis_result.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_bloc.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_event.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_state.dart';

class MockAnalyzeText extends Mock implements AnalyzeText {}

class MockWatchAnalysisResult extends Mock implements WatchAnalysisResult {}

class MockUpdateAnalysisCounts extends Mock implements UpdateAnalysisCounts {}

class MockToggleWordStatus extends Mock implements ToggleWordStatus {}

void main() {
  late AnalyzerBloc bloc;
  late MockAnalyzeText mockAnalyzeText;
  late MockWatchAnalysisResult mockWatchAnalysisResult;
  late MockUpdateAnalysisCounts mockUpdateAnalysisCounts;
  late MockToggleWordStatus mockToggleWordStatus;
  late StreamController<Either<Failure, AnalysisResult>> analysisController;

  setUpAll(() {
    registerFallbackValue(const AnalyzeTextParams(title: '', content: ''));
  });

  setUp(() {
    mockAnalyzeText = MockAnalyzeText();
    mockWatchAnalysisResult = MockWatchAnalysisResult();
    mockUpdateAnalysisCounts = MockUpdateAnalysisCounts();
    mockToggleWordStatus = MockToggleWordStatus();
    analysisController =
        StreamController<Either<Failure, AnalysisResult>>.broadcast();

    when(() => mockWatchAnalysisResult(any()))
        .thenAnswer((_) => analysisController.stream);

    bloc = AnalyzerBloc(
      analyzeText: mockAnalyzeText,
      watchAnalysisResult: mockWatchAnalysisResult,
      updateAnalysisCounts: mockUpdateAnalysisCounts,
      toggleWordStatus: mockToggleWordStatus,
    );
  });

  tearDown(() {
    analysisController.close();
    bloc.close();
  });

  group('AnalyzerBloc SSOT', () {
    const tResult = AnalysisResult(
      id: 1,
      title: 'Test',
      totalWords: 2,
      uniqueWords: 2,
      unknownWords: 1,
      knownWords: 1,
      newWordsCount: 1,
      words: [],
    );

    blocTest<AnalyzerBloc, AnalyzerState>(
      'emits success state when stream emits new result after StartAnalysis',
      build: () => bloc,
      act: (bloc) async {
        when(() => mockAnalyzeText(any()))
            .thenAnswer((_) => TaskEither.of(tResult));
        bloc.add(const StartAnalysis(title: 'Test', content: 'Content'));
        await Future.delayed(Duration.zero);
        analysisController.add(const Right(tResult));
      },
      expect: () => [
        isA<AnalyzerState>()
            .having((s) => s.status.isLoading, 'isLoading', true),
        isA<AnalyzerState>()
            .having((s) => s.status.isSuccess, 'isSuccess', true)
            .having((s) => s.status.data, 'data', tResult),
      ],
    );

    blocTest<AnalyzerBloc, AnalyzerState>(
      'auto-updates state when stream emits updated result (SSOT)',
      build: () => bloc,
      act: (bloc) async {
        when(() => mockAnalyzeText(any()))
            .thenAnswer((_) => TaskEither.of(tResult));
        bloc.add(const StartAnalysis(title: 'Test', content: 'Content'));
        await Future.delayed(Duration.zero);
        analysisController.add(const Right(tResult));
        await Future.delayed(Duration.zero);

        final updatedResult = tResult.copyWith(totalWords: 10);
        analysisController.add(Right(updatedResult));
      },
      skip: 2,
      expect: () => [
        isA<AnalyzerState>()
            .having((s) => s.status.data?.totalWords, 'totalWords', 10),
      ],
    );
  });
}
