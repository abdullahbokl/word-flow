import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/features/vocabulary/data/services/isolate_text_analysis_service.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';

void main() {
  late IsolateTextAnalysisService service;

  const tStopWords = {
    'the', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with',
    'by', 'is', 'am', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has',
    'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should', 'may', 'might',
    'shall', 'can', 'need', 'dare', 'it', 'its', 'he', 'she', 'we', 'they', 'me',
    'him', 'her', 'us', 'them', 'my', 'your', 'his', 'our', 'their', 'this', 'that',
    'these', 'those', 'not', 'no', 'nor', 'so', 'if', 'then', 'than', 'too', 'very',
    'just', 'about', 'also', 'as', 'from', 'up', 'out', 'into', 'over', 'after',
    'before', 'between', 'under', 'again', 'more', 'most', 'other', 'some', 'such',
    'only', 'own', 'same', 'each', 'every', 'both', 'few', 'all', 'any', 'many',
    'much', 'how', 'when', 'where', 'why', 'what', 'which', 'who', 'whom'
  };

  const tConfig = TextAnalysisConfig(
    stopWords: tStopWords,
    language: 'english',
  );

  setUp(() {
    service = IsolateTextAnalysisService();
  });

  group('IsolateTextAnalysisService', () {
    test('1. Empty string returns empty results', () async {
      final result = await service.process(rawText: '', knownWords: {}, config: tConfig);

      expect(result.words, isEmpty);
      expect(result.summary.totalWords, 0);
      expect(result.summary.uniqueWords, 0);
      expect(result.summary.newWords, 0);
    });

    test('2. All stopwords are filtered out', () async {
      const text = 'the and or in on at to for of with';
      final result = await service.process(rawText: text, knownWords: {}, config: tConfig);

      expect(result.words, isEmpty);
      expect(result.summary.totalWords, 10);
      expect(result.summary.uniqueWords, 0);
    });

    test('3. Single unique word works correctly', () async {
      const text = 'Flutter';
      final result = await service.process(rawText: text, knownWords: {}, config: tConfig);

      expect(result.words, hasLength(1));
      expect(result.words.first.wordText, 'flutter');
      expect(result.words.first.totalCount, 1);
      expect(result.summary.uniqueWords, 1);
    });

    test('4. Case normalization merges counts', () async {
      const text = 'Flutter flutter FLUTTER';
      final result = await service.process(rawText: text, knownWords: {}, config: tConfig);

      expect(result.words, hasLength(1));
      expect(result.words.first.wordText, 'flutter');
      expect(result.words.first.totalCount, 3);
    });

    test('5. Apostrophes are handled as part of the word', () async {
      const text = "don't shouldn't it's";
      final result = await service.process(rawText: text, knownWords: {}, config: tConfig);

      expect(result.words.map((w) => w.wordText), containsAll(["don't", "shouldn't", "it's"]));
    });

    test('6. Words with numbers are filtered by regex (no digits)', () async {
      const text = 'web3 flutter2 native';
      final result = await service.process(rawText: text, knownWords: {}, config: tConfig);

      expect(result.words.map((w) => w.wordText), isNot(contains('web')));
      expect(result.words.map((w) => w.wordText), contains('native'));
    });

    test('7. Short words (< 2 chars) are filtered', () async {
      const text = 'I a am Flutter';
      final result = await service.process(rawText: text, knownWords: {}, config: tConfig);

      expect(result.words.map((w) => w.wordText), contains('flutter'));
      expect(result.words.map((w) => w.wordText), isNot(contains('i')));
      expect(result.words.map((w) => w.wordText), isNot(contains('a')));
    });

    test('8. Known words are identified', () async {
      const text = 'learning dart with flutter';
      final known = {'dart'};
      final result = await service.process(rawText: text, knownWords: known, config: tConfig);

      final dart = result.words.firstWhere((w) => w.wordText == 'dart');
      final flutter = result.words.firstWhere((w) => w.wordText == 'flutter');

      expect(dart.isKnown, true);
      expect(flutter.isKnown, false);
    });

    test('9. Sort order: unknown first, then frequency descending', () async {
      const text = 'apple apple banana banana banana cherry';
      final known = {'banana'};
      final result = await service.process(rawText: text, knownWords: known, config: tConfig);

      expect(result.words[0].wordText, 'apple');
      expect(result.words[1].wordText, 'cherry');
      expect(result.words[2].wordText, 'banana');
    });

    test('10. Summary counts are accurate', () async {
      const text = 'Flutter is amazing and extremely fast';
      final result = await service.process(rawText: text, knownWords: {'flutter'}, config: tConfig);
      
      expect(result.summary.totalWords, 6);
      expect(result.summary.uniqueWords, 4);
      expect(result.summary.newWords, 3);
    });

    test('11. Large text performance (< 2s)', () async {
      final largeText = List.generate(10000, (i) => 'Word$i').join(' ');
      
      final stopwatch = Stopwatch()..start();
      await service.process(rawText: largeText, knownWords: {}, config: tConfig);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000), reason: 'Analysis took too long');
    });

    test('12. Hyphenated words are split (default regex behavior)', () async {
      const text = 'well-known developer';
      final result = await service.process(rawText: text, knownWords: {}, config: tConfig);

      expect(result.words.map((w) => w.wordText), contains('well'));
      expect(result.words.map((w) => w.wordText), contains('known'));
      expect(result.words.map((w) => w.wordText), contains('developer'));
    });

    test('13. Text with only punctuation returns empty', () async {
      const text = '!!! ??? ... ,,, ---';
      final result = await service.process(rawText: text, knownWords: {}, config: tConfig);

      expect(result.words, isEmpty);
      expect(result.summary.totalWords, 0);
    });

    test('14. Custom min word length works', () async {
      const text = 'a be see';
      final config = TextAnalysisConfig(
        stopWords: {},
        language: 'english',
        minWordLength: 3,
      );
      final result = await service.process(rawText: text, knownWords: {}, config: config);

      expect(result.words.map((w) => w.wordText), contains('see'));
      expect(result.words.map((w) => w.wordText), isNot(contains('be')));
    });

    test('15. Disabling contractions splitting works', () async {
      const text = "don't";
      final configNoCont = TextAnalysisConfig(
        stopWords: {},
        language: 'english',
        includeContractionsAsOne: false,
      );
      final result = await service.process(rawText: text, knownWords: {}, config: configNoCont);
      
      // If NOT including contractions as one, "don't" matches "don" and then "'" and "t".
      // "don" is len 3, matches. "t" is len 1, filtered (minLen 2).
      expect(result.words.map((w) => w.wordText), contains("don"));
      expect(result.words.map((w) => w.wordText), isNot(contains("don't")));
    });
  });
}
