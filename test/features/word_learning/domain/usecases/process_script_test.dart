import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/word_learning/domain/usecases/process_script.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/vocabulary/domain/services/text_analysis_service.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';

class MockWordRepository extends Mock implements WordRepository {}
class MockTextAnalysisService extends Mock implements TextAnalysisService {}

void main() {
  late ProcessScript useCase;
  late MockWordRepository mockRepository;
  late MockTextAnalysisService mockService;

  setUp(() {
    mockRepository = MockWordRepository();
    mockService = MockTextAnalysisService();
    useCase = ProcessScript(mockRepository, mockService);
  });

  const tRawText = 'Hello world hello';
  const tUserId = 'user-123';

  group('ProcessScript', () {
    test('should return ScriptAnalysis when happy path filtering known words correctly', () async {
      // arrange
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
      )).thenAnswer((_) async => tAnalysis);

      // act
      final result = await useCase(tRawText, userId: tUserId);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (analysis) => expect(analysis, tAnalysis),
      );
      verify(() => mockRepository.getKnownWordTexts(userId: tUserId)).called(1);
      verify(() => mockService.process(rawText: tRawText, knownWords: knownWords)).called(1);
    });

    test('should return empty analysis when script is empty', () async {
      const tEmptyAnalysis = ScriptAnalysis(
        summary: ScriptSummary.empty(),
        words: [],
      );
      
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right([]));
      when(() => mockService.process(rawText: '', knownWords: any(named: 'knownWords')))
          .thenAnswer((_) async => tEmptyAnalysis);

      final result = await useCase('', userId: tUserId);

      expect(result, const Right(tEmptyAnalysis));
    });

    test('should return correct summary and 0 newWords when all words are known', () async {
      final knownWords = {'hello', 'world'};
       when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => Right(knownWords.toList()));

      const tAnalysis = ScriptAnalysis(
        summary: ScriptSummary(totalWords: 2, uniqueWords: 2, newWords: 0),
        words: [
          ProcessedWord(wordText: 'hello', totalCount: 1, isKnown: true),
          ProcessedWord(wordText: 'world', totalCount: 1, isKnown: true),
        ],
      );

      when(() => mockService.process(rawText: any(named: 'rawText'), knownWords: any(named: 'knownWords')))
          .thenAnswer((_) async => tAnalysis);

      final result = await useCase('hello world', userId: tUserId);

      result.fold((_) => fail('should be Right'), (analysis) {
        expect(analysis.summary.newWords, 0);
      });
    });

    test('should fallback to empty known words set when repository call fails (existing behavior)', () async {
      // NOTE: Current behavior documented: repository failures for known words are caught and returned as empty set.
      // Suggestion: In a strict library, we might want to propagate failure, but for offline-first, fallback is safer.
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Left(DatabaseFailure('error')));
      
      when(() => mockService.process(rawText: any(named: 'rawText'), knownWords: any(named: 'knownWords')))
          .thenAnswer((_) async => const ScriptAnalysis(summary: ScriptSummary.empty(), words: []));

      await useCase(tRawText, userId: tUserId);

      // Verify that service was called with empty set
      verify(() => mockService.process(rawText: tRawText, knownWords: {})).called(1);
    });

    test('should return Left(ProcessingFailure) when text analysis service throws', () async {
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right([]));
      
      when(() => mockService.process(rawText: any(named: 'rawText'), knownWords: any(named: 'knownWords')))
          .thenThrow(Exception('service error'));

      final result = await useCase(tRawText, userId: tUserId);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ProcessingFailure>()),
        (_) => fail('should be Left'),
      );
    });

    test('should ensure words are sorted by frequency descending with known words last', () async {
      // Create unsorted words
      final words = [
        const ProcessedWord(wordText: 'common', totalCount: 5, isKnown: true),
        const ProcessedWord(wordText: 'rare-new', totalCount: 1, isKnown: false),
        const ProcessedWord(wordText: 'common-new', totalCount: 10, isKnown: false),
        const ProcessedWord(wordText: 'rare', totalCount: 2, isKnown: true),
      ];

      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right([]));
      
      when(() => mockService.process(rawText: any(named: 'rawText'), knownWords: any(named: 'knownWords')))
          .thenAnswer((_) async => ScriptAnalysis(
            summary: const ScriptSummary(totalWords: 18, uniqueWords: 4, newWords: 2),
            words: words,
          ));

      final result = await useCase(tRawText);

      result.fold(
        (failure) => fail('Should be Right: $failure'),
        (analysis) {
          // Expected: common-new(10), rare-new(1), common(5, known), rare(2, known)
          // Actually, based on IsolateTextAnalysisService: 
          // known words last, then counts.
          // Wait, 'common-new' (false, 10), 'rare-new' (false, 1), 'common' (true, 5), 'rare' (true, 2)
          expect(analysis.words[0].wordText, 'common-new');
          expect(analysis.words[1].wordText, 'rare-new');
          expect(analysis.words[2].wordText, 'common');
          expect(analysis.words[3].wordText, 'rare');
        },
      );
    });
  });
}
