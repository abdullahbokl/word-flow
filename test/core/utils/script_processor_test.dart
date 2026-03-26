import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/utils/script_analysis.dart';
import 'package:word_flow/core/utils/script_processor.dart';

void main() {
  group('ScriptProcessor', () {
    test('should extract words and count frequencies', () async {
      const text = 'Hello world, hello again!';
      final result = await ScriptProcessor.process(
        rawText: text,
        knownWords: {},
      );

      expect(result.summary, const ScriptSummary(totalWords: 4, uniqueWords: 3, newWords: 3));
      expect(result.words.length, 3);
      expect(result.words.any((w) => w.wordText == 'hello' && w.totalCount == 2), true);
      expect(result.words.any((w) => w.wordText == 'world' && w.totalCount == 1), true);
      expect(result.words.any((w) => w.wordText == 'again' && w.totalCount == 1), true);
    });

    test('should filter out known words', () async {
      const text = 'Apple banana apple cherry';
      final result = await ScriptProcessor.process(
        rawText: text,
        knownWords: {'apple'},
      );

      expect(result.summary, const ScriptSummary(totalWords: 4, uniqueWords: 3, newWords: 2));
      expect(result.words.length, 2);
      expect(result.words.any((w) => w.wordText == 'apple'), false);
      expect(result.words.any((w) => w.wordText == 'banana'), true);
      expect(result.words.any((w) => w.wordText == 'cherry'), true);
    });

    test('should handle punctuation and case', () async {
      const text = "It's a test! (test, test: TEST).";
      final result = await ScriptProcessor.process(
        rawText: text,
        knownWords: {},
      );

      // words: it's, a, test, test, test, test
      expect(result.summary, const ScriptSummary(totalWords: 6, uniqueWords: 3, newWords: 3));
      expect(result.words.any((w) => w.wordText == "it's"), true);
      expect(result.words.any((w) => w.wordText == "test" && w.totalCount == 4), true);
    });
  });
}
