import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/word_learning/domain/usecases/process_script.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/vocabulary/domain/services/text_analysis_service.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';

class MockWordRepository extends Mock implements WordRepository {}
class MockTextAnalysisService extends Mock implements TextAnalysisService {}

void main() {
  late ProcessScript useCase;
  late MockWordRepository mockRepository;
  late MockTextAnalysisService mockService;

  const tConfig = TextAnalysisConfig(
    stopWords: {'the', 'a'},
    language: 'english',
  );

  setUpAll(() {
    registerFallbackValue(tConfig);
  });

  setUp(() {
    mockRepository = MockWordRepository();
    mockService = MockTextAnalysisService();
    useCase = ProcessScript(mockRepository, mockService);
  });

  const tRawText = 'Hello world hello';
  const tUserId = 'user-123';

  group('ProcessScript', () {
    test('should return ScriptAnalysis when happy path filtering known words correctly', () async {
      final knownWords = {'hello'};
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => Right(knownWords.toList()));
      
      const tAnalysis = ScriptAnalysis(
        summary: ScriptSummary(totalWords: 3, uniqueWords: 2, newWords: 1),
        words: [
          ProcessedWord(wordText: 'world', totalCount: 1, isKnown: false),
          ProcessedWord(wordText: 'hello', totalCount: 2, isKnown: true),
        ],
      );

      when(() => mockService.process(
        rawText: tRawText,
        knownWords: any(named: 'knownWords'),
        config: any(named: 'config'),
      )).thenAnswer((_) async => tAnalysis);

      final result = await useCase(tRawText, userId: tUserId, config: tConfig);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (analysis) => expect(analysis, tAnalysis),
      );
      verify(() => mockRepository.getKnownWordTexts(userId: tUserId)).called(1);
      verify(() => mockService.process(rawText: tRawText, knownWords: knownWords, config: tConfig)).called(1);
    });

    test('should return empty analysis when script is empty', () async {
      const tEmptyAnalysis = ScriptAnalysis(
        summary: ScriptSummary.empty(),
        words: [],
      );
      
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right([]));
      when(() => mockService.process(rawText: '', knownWords: any(named: 'knownWords'), config: any(named: 'config')))
          .thenAnswer((_) async => tEmptyAnalysis);

      final result = await useCase('', userId: tUserId, config: tConfig);

      expect(result, const Right(tEmptyAnalysis));
    });

    test('should fallback to empty known words set when repository call fails', () async {
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Left(DatabaseFailure('error')));
      
      when(() => mockService.process(rawText: any(named: 'rawText'), knownWords: any(named: 'knownWords'), config: any(named: 'config')))
          .thenAnswer((_) async => const ScriptAnalysis(summary: ScriptSummary.empty(), words: []));

      await useCase(tRawText, userId: tUserId, config: tConfig);

      verify(() => mockService.process(rawText: tRawText, knownWords: {}, config: tConfig)).called(1);
    });

    test('should return Left(ProcessingFailure) when text analysis service throws', () async {
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right([]));
      
      when(() => mockService.process(rawText: any(named: 'rawText'), knownWords: any(named: 'knownWords'), config: any(named: 'config')))
          .thenThrow(Exception('service error'));

      final result = await useCase(tRawText, userId: tUserId, config: tConfig);

      expect(result.isLeft(), true);
    });
  });
}
