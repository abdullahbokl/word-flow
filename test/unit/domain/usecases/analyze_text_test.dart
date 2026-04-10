import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:lexitrack/features/text_analyzer/domain/repositories/analyzer_repository.dart';
import 'package:lexitrack/features/text_analyzer/domain/usecases/analyze_text.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyzerRepository extends Mock implements AnalyzerRepository {}

void main() {
  late AnalyzeText usecase;
  late MockAnalyzerRepository repository;

  setUp(() {
    repository = MockAnalyzerRepository();
    usecase = AnalyzeText(repository);
  });

  group('AnalyzeText', () {
    test('returns validation failure when title is empty', () async {
      final result = await usecase(
              const AnalyzeTextParams(title: '', content: 'some text'))
          .run();

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Expected left'),
      );
    });

    test('returns validation failure when content is empty', () async {
      final result =
          await usecase(const AnalyzeTextParams(title: 'Test', content: ''))
              .run();

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Expected left'),
      );
    });

    test('returns valid content when input is valid', () async {
      when(() => repository.analyze(
            title: any(named: 'title'),
            content: any(named: 'content'),
          )).thenAnswer(
        (_) => TaskEither.right(
          const AnalysisResult(
            id: 1,
            title: 'Test',
            totalWords: 10,
            uniqueWords: 5,
            knownWords: 3,
            unknownWords: 2,
            newWordsCount: 2,
            words: [],
          ),
        ),
      );

      final result = await usecase(
              const AnalyzeTextParams(title: 'Test', content: 'Hello world'))
          .run();

      expect(result.isRight(), true);
    });

    test('calls repository.analyze with correct parameters', () async {
      when(() => repository.analyze(
            title: any(named: 'title'),
            content: any(named: 'content'),
          )).thenAnswer(
        (_) => TaskEither.right(
          const AnalysisResult(
            id: 1,
            title: 'Test',
            totalWords: 10,
            uniqueWords: 5,
            knownWords: 3,
            unknownWords: 2,
            newWordsCount: 2,
            words: [],
          ),
        ),
      );

      await usecase(const AnalyzeTextParams(
              title: 'My Title', content: 'Hello world'))
          .run();

      verify(() =>
              repository.analyze(title: 'My Title', content: 'Hello world'))
          .called(1);
    });
  });
}
