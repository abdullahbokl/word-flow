import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/features/vocabulary/data/services/isolate_text_analysis_service.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';

void main() {
  group('IsolateTextAnalysisService', () {
    final service = IsolateTextAnalysisService();

    test('should extract words and count frequencies', () async {
      const text = 'Hello world, hello planet!';
      final result = await service.process(
        rawText: text,
        knownWords: {},
      );

      expect(result.summary, const ScriptSummary(totalWords: 4, uniqueWords: 3, newWords: 3));
      expect(result.words.length, 3);
      expect(result.words.any((w) => w.wordText == 'hello' && w.totalCount == 2), true);
      expect(result.words.any((w) => w.wordText == 'world' && w.totalCount == 1), true);
      expect(result.words.any((w) => w.wordText == 'planet' && w.totalCount == 1), true);
    });

    test('should tag known words without filtering them out', () async {
      const text = 'Apple banana apple cherry';
      final result = await service.process(
        rawText: text,
        knownWords: {'apple'},
      );

      expect(result.summary, const ScriptSummary(totalWords: 4, uniqueWords: 3, newWords: 2));
      expect(result.words.length, 3);
      expect(result.words.any((w) => w.wordText == 'apple' && w.isKnown == true), true);
      expect(result.words.any((w) => w.wordText == 'banana' && w.isKnown == false), true);
      expect(result.words.any((w) => w.wordText == 'cherry' && w.isKnown == false), true);
    });

    test('should handle punctuation and case', () async {
      const text = "It's a test! (test, test: TEST).";
      final result = await service.process(
        rawText: text,
        knownWords: {},
      );

      // regex words: it's, test, test, test, test
      expect(result.summary, const ScriptSummary(totalWords: 5, uniqueWords: 2, newWords: 2));
      expect(result.words.any((w) => w.wordText == "it's"), true);
      expect(result.words.any((w) => w.wordText == 'test' && w.totalCount == 4), true);
    });

    test('should filter stop words while preserving totalWords count', () async {
      const text = 'The cat and the dog are in the yard';
      final result = await service.process(
        rawText: text,
        knownWords: {},
      );

      expect(result.summary.totalWords, 9);
      expect(result.summary.uniqueWords, 3);
      expect(result.words.any((w) => w.wordText == 'the'), false);
      expect(result.words.any((w) => w.wordText == 'and'), false);
      expect(result.words.any((w) => w.wordText == 'are'), false);
      expect(result.words.any((w) => w.wordText == 'cat' && w.totalCount == 1), true);
      expect(result.words.any((w) => w.wordText == 'dog' && w.totalCount == 1), true);
      expect(result.words.any((w) => w.wordText == 'yard' && w.totalCount == 1), true);
    });

    test('should keep contractions and remove single-letter tokens', () async {
      const text = "I can't say it's a win, but don't quit.";
      final result = await service.process(
        rawText: text,
        knownWords: {},
      );

      expect(result.summary.totalWords, 7);
      expect(result.words.any((w) => w.wordText == "can't"), true);
      expect(result.words.any((w) => w.wordText == "it's"), true);
      expect(result.words.any((w) => w.wordText == "don't"), true);
      expect(result.words.any((w) => w.wordText == 'i'), false);
      expect(result.words.any((w) => w.wordText == 'a'), false);
    });
  });
}
