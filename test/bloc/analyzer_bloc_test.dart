import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/core/error/failures.dart';
import '../../lib/features/text_analyzer/domain/entities/analysis_result.dart';
import '../../lib/features/text_analyzer/domain/repositories/analyzer_repository.dart';
import '../../lib/features/text_analyzer/domain/usecases/analyze_text.dart';
import '../../lib/features/text_analyzer/presentation/bloc/analyzer_bloc.dart';
import '../../lib/features/text_analyzer/presentation/bloc/analyzer_event.dart';
import '../../lib/features/text_analyzer/presentation/bloc/analyzer_state.dart';

class MockAnalyzerRepository extends Mock implements AnalyzerRepository {}

AnalysisResult _makeResult({int id = 1}) {
  return AnalysisResult(
    id: id,
    title: 'Test',
    totalWords: 10,
    uniqueWords: 5,
    knownWords: 3,
    unknownWords: 2,
    newWordsCount: 0,
    words: [],
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_makeResult());
  });

  late MockAnalyzerRepository repository;
  late AnalyzeText usecase;
  late AnalyzerBloc bloc;

  setUp(() {
    repository = MockAnalyzerRepository();
    usecase = AnalyzeText(repository);
    bloc = AnalyzerBloc(analyzeText: usecase);
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
        isA<AnalyzerState>().having((s) => s.status.isLoading, 'isLoading', true),
        isA<AnalyzerState>().having((s) => s.status.isSuccess, 'isSuccess', true),
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
        isA<AnalyzerState>().having((s) => s.status.isLoading, 'isLoading', true),
        isA<AnalyzerState>().having((s) => s.status.isFailed, 'isFailed', true),
      ],
    );

    blocTest<AnalyzerBloc, AnalyzerState>(
      'emits reset state on ResetAnalysis',
      build: () => bloc,
      seed: () => AnalyzerState(
        status: const BlocStatus.success(data: _AnalysisResult(id: 1)),
      ),
      act: (b) => b.add(const ResetAnalysis()),
      expect: () => [
        isA<AnalyzerState>().having((s) => s.status.isInitial, 'isInitial', true),
      ],
    );
  });
}

class _AnalysisResult extends AnalysisResult {
  const _AnalysisResult({required int id})
      : super(
          id: id,
          title: 'Test',
          totalWords: 10,
          uniqueWords: 5,
          knownWords: 3,
          unknownWords: 2,
          newWordsCount: 0,
          words: [],
        );
}
