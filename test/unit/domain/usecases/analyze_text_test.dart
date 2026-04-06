import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../lib/core/error/failures.dart';
import '../../../lib/features/text_analyzer/domain/entities/analysis_result.dart';
import '../../../lib/features/text_analyzer/domain/repositories/analyzer_repository.dart';
import '../../../lib/features/text_analyzer/domain/usecases/analyze_text.dart';

class MockAnalyzerRepository extends Mock implements AnalyzerRepository {}

void main() {
  late AnalyzeText usecase;
  late MockAnalyzerRepository repository;

  setUp(() {
    repository = MockAnalyzerRepository();
    usecase = AnalyzeText(repository);
  });

  group('AnalyzeText', () {
    test('returns validation failure when title is empty', () {
      final result = usecase.call(title: '', content: 'some text');

      expect(result.isLeft(), true);
      final failure = (result as Left).value;
      expect(failure, isA<ValidationFailure>());
    });

    test('returns validation failure when content is empty', () {
      final result = usecase.call(title: 'Test', content: '');

      expect(result.isLeft(), true);
      final failure = (result as Left).value;
      expect(failure, isA<ValidationFailure>());
    });

    test('returns valid content', () {
      when(() => repository.analyze(
            title: any(named: 'title'),
            content: any(named: 'content'),
          )).thenAnswer(
        (_) => TaskEither.right(
          AnalysisResult(
            title: 'Test',
            totalWords: 10,
            uniqueWords: 5,
            knownWords: 3,
            unknownWords: 2,
            comprehension: 80.0,
            words: [],
          ),
        ),
      );

      final result = usecase.call(title: 'Test', content: 'Hello world');

      expect(result.isRight(), true);
    });
  });
}
