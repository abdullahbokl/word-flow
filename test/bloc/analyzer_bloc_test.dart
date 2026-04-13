import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/common/models/word_with_local_freq.dart';
import 'package:lexitrack/core/common/state/bloc_status.dart';
import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:lexitrack/features/text_analyzer/domain/repositories/analyzer_repository.dart';
import 'package:lexitrack/features/text_analyzer/domain/usecases/analyze_text.dart';
import 'package:lexitrack/features/text_analyzer/domain/usecases/get_analysis_result.dart';
import 'package:lexitrack/features/text_analyzer/domain/usecases/update_analysis_counts.dart';
import 'package:lexitrack/features/text_analyzer/presentation/blocs/analyzer/analyzer_bloc.dart';
import 'package:lexitrack/features/text_analyzer/presentation/blocs/analyzer/analyzer_event.dart';
import 'package:lexitrack/features/text_analyzer/presentation/blocs/analyzer/analyzer_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyzerRepository extends Mock implements AnalyzerRepository {}

WordWithLocalFreq _makeWord({
  required int id,
  required String text,
  required bool isKnown,
  required int localFrequency,
}) {
  return WordWithLocalFreq(
    word: WordEntity(
      id: id,
      text: text,
      frequency: localFrequency,
      isKnown: isKnown,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
    localFrequency: localFrequency,
  );
}

AnalysisResult _makeResult({int id = 1}) {
  return AnalysisResult(
    id: id,
    title: 'Test',
    totalWords: 10,
    uniqueWords: 2,
    knownWords: 1,
    unknownWords: 1,
    newWordsCount: 0,
    words: [
      _makeWord(id: 1, text: 'alpha', isKnown: false, localFrequency: 4),
      _makeWord(id: 2, text: 'beta', isKnown: true, localFrequency: 6),
    ],
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_makeResult());
  });

  late MockAnalyzerRepository repository;
  late AnalyzeText analyzeText;
  late GetAnalysisResult getAnalysisResult;
  late UpdateAnalysisCounts updateAnalysisCounts;
  late AnalyzerBloc bloc;

  setUp(() {
    repository = MockAnalyzerRepository();
    analyzeText = AnalyzeText(repository);
    getAnalysisResult = GetAnalysisResult(repository);
    updateAnalysisCounts = UpdateAnalysisCounts(repository);
    bloc = AnalyzerBloc(
      analyzeText: analyzeText,
      getAnalysisResult: getAnalysisResult,
      updateAnalysisCounts: updateAnalysisCounts,
    );
  });

  tearDown(() => bloc.close());

  group('AnalyzerBloc', () {
    blocTest<AnalyzerBloc, AnalyzerState>(
      'emits loading then success on StartAnalysis',
      build: () {
        when(() => repository.analyze(
              title: any(named: 'title'),
              content: any(named: 'content'),
            )).thenAnswer((_) => TaskEither.right(_makeResult()));
        return bloc;
      },
      act: (b) => b.add(const StartAnalysis(title: 'Test', content: 'Hello')),
      expect: () => [
        isA<AnalyzerState>()
            .having((s) => s.status.isLoading, 'isLoading', true),
        isA<AnalyzerState>()
            .having((s) => s.status.isSuccess, 'isSuccess', true),
      ],
    );

    blocTest<AnalyzerBloc, AnalyzerState>(
      'emits loading then failure on error',
      build: () {
        when(() => repository.analyze(
              title: any(named: 'title'),
              content: any(named: 'content'),
            )).thenAnswer(
          (_) => TaskEither.left(const DatabaseFailure('db error')),
        );
        return bloc;
      },
      act: (b) => b.add(const StartAnalysis(title: 'Test', content: 'Hello')),
      expect: () => [
        isA<AnalyzerState>()
            .having((s) => s.status.isLoading, 'isLoading', true),
        isA<AnalyzerState>().having((s) => s.status.isFailed, 'isFailed', true),
      ],
    );

    blocTest<AnalyzerBloc, AnalyzerState>(
      'emits reset state on ResetAnalysis',
      build: () => bloc,
      seed: () => AnalyzerState(
        status: BlocStatus.success(data: _makeResult()),
      ),
      act: (b) => b.add(const ResetAnalysis()),
      expect: () => [
        isA<AnalyzerState>()
            .having((s) => s.status.isInitial, 'isInitial', true),
      ],
    );

    blocTest<AnalyzerBloc, AnalyzerState>(
      'toggles a single word without rescanning the whole result',
      build: () {
        when(() => repository.updateAnalysisCounts(any()))
            .thenAnswer((_) => TaskEither.right(unit));
        return bloc;
      },
      seed: () => AnalyzerState(
        status: BlocStatus.success(data: _makeResult()),
      ),
      act: (b) => b.add(const ToggleWordStatusInResult(wordId: 1)),
      expect: () => [
        isA<AnalyzerState>()
            .having((s) => s.status.isSuccess, 'isSuccess', true)
            .having((s) => s.status.data!.knownWords, 'knownWords', 2) // 1 + 1
            .having(
                (s) => s.status.data!.unknownWords, 'unknownWords', 0) // 1 - 1
            .having((s) => s.status.data!.words.first.word.isKnown,
                'first word isKnown', true),
      ],
    );
  });
}
