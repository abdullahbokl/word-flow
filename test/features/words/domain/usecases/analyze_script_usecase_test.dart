import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/features/words/domain/usecases/analyze_script_usecase.dart';
import 'package:word_flow/features/words/repositories/word_repository.dart';
import 'package:word_flow/features/words/repositories/text_analysis_service.dart';
import 'package:word_flow/features/words/models/analysis.dart';

class MockWordRepository extends Mock implements WordRepository {}
class MockTextAnalysisService extends Mock implements TextAnalysisService {}

class TextAnalysisConfigFake extends Fake implements TextAnalysisConfig {}

void main() {
  late AnalyzeScriptUseCase useCase;
  late MockWordRepository mockWordRepository;
  late MockTextAnalysisService mockTextAnalysisService;

  setUpAll(() {
    registerFallbackValue(TextAnalysisConfigFake());
  });

  setUp(() {
    mockWordRepository = MockWordRepository();
    mockTextAnalysisService = MockTextAnalysisService();
    useCase = AnalyzeScriptUseCase(mockWordRepository, mockTextAnalysisService);
  });

  const tConfig = TextAnalysisConfig(
    stopWords: {},
    language: 'english',
  );

  test('should return empty analysis when text is empty', () async {
    final result = await useCase(const AnalyzeScriptParams(text: '', config: tConfig));

    expect(result.isRight(), true);
    result.fold(
      (l) => fail('Should be right'),
      (r) {
        expect(r.words, isEmpty);
        expect(r.summary.totalWords, 0);
      },
    );
  });

  test('should call repository and service when text is not empty', () async {
    const tText = 'hello world';
    final tKnownWords = ['hello'];
    const tAnalysis = ScriptAnalysis(
      summary: ScriptSummary(totalWords: 2, uniqueWords: 2, newWords: 1),
      words: [
        AnalyzedWord(wordText: 'hello', totalCount: 1, isKnown: true),
        AnalyzedWord(wordText: 'world', totalCount: 1, isKnown: false),
      ],
    );

    when(() => mockWordRepository.getKnownWordTexts())
        .thenAnswer((_) async => Right(tKnownWords));
    when(() => mockTextAnalysisService.analyze(
          rawText: any(named: 'rawText'),
          knownWords: any(named: 'knownWords'),
          config: any(named: 'config'),
        )).thenAnswer((_) async => tAnalysis);

    final result = await useCase(const AnalyzeScriptParams(text: tText, config: tConfig));

    expect(result, const Right(tAnalysis));
    verify(() => mockWordRepository.getKnownWordTexts()).called(1);
    verify(() => mockTextAnalysisService.analyze(
          rawText: tText,
          knownWords: tKnownWords.toSet(),
          config: tConfig,
        )).called(1);
  });
}
