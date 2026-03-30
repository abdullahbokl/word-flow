import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/features/word_learning/domain/usecases/process_script.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/core/errors/failures.dart';
import '../../../../helpers/mock_dependencies.dart';

void main() {
  late ProcessScript useCase;
  late MockWordRepository mockRepository;
  late MockTextAnalysisService mockAnalysisService;

  const tConfig = TextAnalysisConfig(
    useStemming: true,
    stopWords: {'the', 'a', 'is'},
    language: 'en',
    minWordLength: 1,
  );

  setUpAll(() {
    registerFallbackValue(const TextAnalysisConfig(
      useStemming: false,
      stopWords: {},
      language: 'en',
      minWordLength: 1,
    ));
  });

  setUp(() {
    mockRepository = MockWordRepository();
    mockAnalysisService = MockTextAnalysisService();
    useCase = ProcessScript(mockRepository, mockAnalysisService);
  });

  test('Successfully processes a normal script', () async {
    // Arrange
    const rawText = 'Hello world, hello again.';
    const analysisResult = ScriptAnalysis(
      summary: ScriptSummary(totalWords: 4, uniqueWords: 3, newWords: 2),
      words: [
        ProcessedWord(wordText: 'hello', totalCount: 2, isKnown: true),
        ProcessedWord(wordText: 'world', totalCount: 1, isKnown: false),
        ProcessedWord(wordText: 'again', totalCount: 1, isKnown: false),
      ],
    );

    when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
        .thenAnswer((_) async => const Right(['hello']));
    when(() => mockAnalysisService.process(
          rawText: any(named: 'rawText'),
          knownWords: any(named: 'knownWords'),
          config: any(named: 'config'),
        )).thenAnswer((_) async => analysisResult);

    // Act
    final result = await useCase(rawText, config: tConfig);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (l) => fail('Should be Right'),
      (r) {
        expect(r.summary.totalWords, 4);
        expect(r.words.length, 3);
      },
    );
  });

  test('Filters out empty input with ProcessingFailure', () async {
    // Act
    final result = await useCase('   ', config: tConfig);

    // Assert
    expect(result.isLeft(), true);
    expect(result.getLeft().toNullable() is ProcessingFailure, true);
  });

  test('Handles very long input (>500KB) with ProcessingFailure', () async {
    // Arrange
    final longText = 'a' * (500 * 1024 + 1);

    // Act
    final result = await useCase(longText, config: tConfig);

    // Assert
    expect(result.isLeft(), true);
    expect(result.getLeft().toNullable() is ProcessingFailure, true);
  });

  test('Sorts results: unknown words first, then by frequency descending', () async {
    // Arrange
    const rawText = 'sample text';
    const unsortedResult = ScriptAnalysis(
      summary: ScriptSummary(totalWords: 4, uniqueWords: 4, newWords: 3),
      words: [
        ProcessedWord(wordText: 'known', totalCount: 10, isKnown: true),
        ProcessedWord(wordText: 'unknown1', totalCount: 2, isKnown: false),
        ProcessedWord(wordText: 'unknown2', totalCount: 5, isKnown: false),
        ProcessedWord(wordText: 'known2', totalCount: 1, isKnown: true),
      ],
    );

    when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
        .thenAnswer((_) async => const Right([]));
    when(() => mockAnalysisService.process(
          rawText: any(named: 'rawText'),
          knownWords: any(named: 'knownWords'),
          config: any(named: 'config'),
        )).thenAnswer((_) async => unsortedResult);

    // Act
    final result = await useCase(rawText, config: tConfig);

    // Assert
    result.fold(
      (l) => fail('Should be Right'),
      (r) {
        // Expected order: unknown2 (5), unknown1 (2), known (10), known2 (1)
        expect(r.words[0].wordText, 'unknown2');
        expect(r.words[1].wordText, 'unknown1');
        expect(r.words[2].wordText, 'known');
        expect(r.words[3].wordText, 'known2');
      },
    );
  });

  test('Handles repository failure gracefully by using empty known set', () async {
    // Arrange
    const rawText = 'sample';
    const analysisResult = ScriptAnalysis(
      summary: ScriptSummary(totalWords: 1, uniqueWords: 1, newWords: 1),
      words: [ProcessedWord(wordText: 'sample', totalCount: 1, isKnown: false)],
    );

    when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
        .thenAnswer((_) async => const Left(ServerFailure('DB Error')));
    when(() => mockAnalysisService.process(
          rawText: any(named: 'rawText'),
          knownWords: const {},
          config: any(named: 'config'),
        )).thenAnswer((_) async => analysisResult);

    // Act
    final result = await useCase(rawText, config: tConfig);

    // Assert
    expect(result.isRight(), true);
    verify(() => mockAnalysisService.process(
          rawText: any(named: 'rawText'),
          knownWords: const {},
          config: any(named: 'config'),
        )).called(1);
  });

  // Note: Case insensitivity and apostrophes are typically handled by TextAnalysisService.
  // We mock that service here, so we verify that the service is called with the sanitized text.
  test('Sanitizes input before passing to analysis service', () async {
    // Arrange
    const rawText = 'Hello\x00World'; // Control character
    const expectedSanitized = 'HelloWorld';

    when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
        .thenAnswer((_) async => const Right([]));
    when(() => mockAnalysisService.process(
          rawText: expectedSanitized,
          knownWords: any(named: 'knownWords'),
          config: any(named: 'config'),
        )).thenAnswer((_) async => const ScriptAnalysis(
          summary: ScriptSummary.empty(),
          words: [],
        ));

    // Act
    await useCase(rawText, config: tConfig);

    // Assert
    verify(() => mockAnalysisService.process(
          rawText: expectedSanitized,
          knownWords: any(named: 'knownWords'),
          config: any(named: 'config'),
        )).called(1);
  });
}
