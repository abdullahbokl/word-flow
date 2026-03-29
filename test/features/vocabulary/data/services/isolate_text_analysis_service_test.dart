import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/features/vocabulary/data/services/isolate_text_analysis_service.dart';

void main() {
  late IsolateTextAnalysisService service;

  setUp(() {
    service = IsolateTextAnalysisService();
  });

  group('IsolateTextAnalysisService', () {
    test('1. Empty string returns empty results', () async {
      final result = await service.process(rawText: '', knownWords: {});

      expect(result.words, isEmpty);
      expect(result.summary.totalWords, 0);
      expect(result.summary.uniqueWords, 0);
      expect(result.summary.newWords, 0);
    });

    test('2. All stopwords are filtered out', () async {
      const text = 'the and or in on at to for of with';
      final result = await service.process(rawText: text, knownWords: {});

      expect(result.words, isEmpty);
      expect(result.summary.totalWords, 10); // Matches all but filtered in wordCounts
      expect(result.summary.uniqueWords, 0);
    });

    test('3. Single unique word works correctly', () async {
      const text = 'Flutter';
      final result = await service.process(rawText: text, knownWords: {});

      expect(result.words, hasLength(1));
      expect(result.words.first.wordText, 'flutter');
      expect(result.words.first.totalCount, 1);
      expect(result.summary.uniqueWords, 1);
    });

    test('4. Case normalization merges counts', () async {
      const text = 'Flutter flutter FLUTTER';
      final result = await service.process(rawText: text, knownWords: {});

      expect(result.words, hasLength(1));
      expect(result.words.first.wordText, 'flutter');
      expect(result.words.first.totalCount, 3);
    });

    test('5. Apostrophes are handled as part of the word', () async {
      const text = "don't shouldn't it's";
      final result = await service.process(rawText: text, knownWords: {});

      // 'it's' might be partially filtered if 'it' is a stopword but the regex \b... matches it fully?
      // Wait, 'it' is a stopword. Let's see if 'it's' is filtered.
      // Stopwords check normalizedWord. Regex matches it's.
      // 'it's' is NOT in the stopwatch list.
      expect(result.words.map((w) => w.wordText), containsAll(["don't", "shouldn't", "it's"]));
    });

    test('6. Words with numbers are filtered by regex (no digits)', () async {
      const text = 'web3 flutter2 native';
      final result = await service.process(rawText: text, knownWords: {});

      // web3 -> \bweb matches but then 3 is not [a-zA-Z]. So it matches 'web'?
      // Regex: \b[a-zA-Z]{2,}(?:'[a-zA-Z]+)?\b
      // 'web3' -> \b starts at 'w'. 'web' matches [a-zA-Z]{2,}. 
      // Then next char is '3'. Regex \b requires a word boundary after the match.
      // Is '3' a word boundary? No, \b matches position between word char and non-word char.
      // 'b' is a word char, '3' is a word char. So NO \b between 'b' and '3'.
      // Thus 'web' in 'web3' does NOT match because it can't find a boundary after 'b'.
      // If it tries to match 'web3', it fails because '3' is not in [a-zA-Z].
      expect(result.words.map((w) => w.wordText), isNot(contains('web')));
      expect(result.words.map((w) => w.wordText), contains('native'));
    });

    test('7. Short words (< 2 chars) are filtered', () async {
      const text = 'I a am Flutter';
      final result = await service.process(rawText: text, knownWords: {});

      // 'am' is a stopword.
      expect(result.words.map((w) => w.wordText), contains('flutter'));
      expect(result.words.map((w) => w.wordText), isNot(contains('i')));
      expect(result.words.map((w) => w.wordText), isNot(contains('a')));
    });

    test('8. Known words are identified', () async {
      const text = 'learning dart with flutter';
      final known = {'dart'};
      final result = await service.process(rawText: text, knownWords: known);

      final dart = result.words.firstWhere((w) => w.wordText == 'dart');
      final flutter = result.words.firstWhere((w) => w.wordText == 'flutter');

      expect(dart.isKnown, true);
      expect(flutter.isKnown, false);
    });

    test('9. Sort order: unknown first, then frequency descending', () async {
      const text = 'apple apple banana banana banana cherry';
      final known = {'banana'}; // banana appears 3 times but is known
      
      final result = await service.process(rawText: text, knownWords: known);

      // result.words should be: [apple (2), cherry (1), banana (3)]
      expect(result.words[0].wordText, 'apple');
      expect(result.words[1].wordText, 'cherry');
      expect(result.words[2].wordText, 'banana');
    });

    test('10. Summary counts are accurate', () async {
      const text = 'Flutter is amazing and extremely fast';
      // Tokens: [Flutter, is, amazing, and, extremely, fast] -> 6 total
      // Stopwords: [is, and] -> 2 filtered
      // Unique: [flutter, amazing, extremely, fast] -> 4 unique
      
      final result = await service.process(rawText: text, knownWords: {'flutter'});
      
      expect(result.summary.totalWords, 6);
      expect(result.summary.uniqueWords, 4);
      expect(result.summary.newWords, 3); // amazing, extremely, fast
    });

    test('11. Large text performance (< 2s)', () async {
      final largeText = List.generate(10000, (i) => 'Word$i').join(' ');
      
      final stopwatch = Stopwatch()..start();
      await service.process(rawText: largeText, knownWords: {});
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000), reason: 'Analysis took too long');
    });

    test('12. Hyphenated words are split (default regex behavior)', () async {
      const text = 'well-known developer';
      final result = await service.process(rawText: text, knownWords: {});

      // Regex \b... matches 'well' and 'known' separately because '-' is a non-word char and creates boundaries.
      expect(result.words.map((w) => w.wordText), contains('well'));
      expect(result.words.map((w) => w.wordText), contains('known'));
      expect(result.words.map((w) => w.wordText), contains('developer'));
    });

    test('13. Text with only punctuation returns empty', () async {
      const text = '!!! ??? ... ,,, ---';
      final result = await service.process(rawText: text, knownWords: {});

      expect(result.words, isEmpty);
      expect(result.summary.totalWords, 0);
    });

    test('Apostrophes inside words: should treat as one word only if matching regex', () async {
      const text = "He's reading a book";
      // He's -> matches
      // reading -> matches
      // book -> matches
      // a -> short
      final result = await service.process(rawText: text, knownWords: {});
      
      expect(result.words.map((w) => w.wordText), contains("he's"));
      expect(result.words.map((w) => w.wordText), contains("reading"));
      expect(result.words.map((w) => w.wordText), contains("book"));
    });
  });
}
