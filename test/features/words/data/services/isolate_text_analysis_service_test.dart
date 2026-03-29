import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/features/words/data/services/isolate_text_analysis_service.dart';
import 'package:word_flow/features/words/domain/entities/processed_word.dart';

void main() {
  late IsolateTextAnalysisService service;

  setUp(() {
    service = IsolateTextAnalysisService();
  });

  group('IsolateTextAnalysisService.process', () {
    group('Word frequency counting', () {
      test('should count word frequencies correctly', () async {
        final result = await service.process(
          rawText: 'hello world hello flutter world hello',
          knownWords: {},
        );
        
        final hello = result.words.firstWhere((w) => w.wordText == 'hello');
        expect(hello.totalCount, 3);
        
        final world = result.words.firstWhere((w) => w.wordText == 'world');
        expect(world.totalCount, 2);
        
        final flutter = result.words.firstWhere((w) => w.wordText == 'flutter');
        expect(flutter.totalCount, 1);
      });

      test('should normalize case (case-insensitive)', () async {
        final result = await service.process(
          rawText: 'Hello HELLO hello HeLLo',
          knownWords: {},
        );
        
        // All should be merged into one entry with lowercase
        expect(result.words.length, 1);
        expect(result.words.first.totalCount, 4);
        expect(result.words.first.wordText, 'hello');
      });

      test('should sort unknown words before known words', () async {
        final result = await service.process(
          rawText: 'hello world flutter dart python',
          knownWords: {'hello', 'world'},
        );
        
        // Unknown words should come before known words
        final unknownIndices = result.words
            .asMap()
            .entries
            .where((e) => !e.value.isKnown)
            .map((e) => e.key)
            .toList();
        
        final knownIndices = result.words
            .asMap()
            .entries
            .where((e) => e.value.isKnown)
            .map((e) => e.key)
            .toList();
        
        if (unknownIndices.isNotEmpty && knownIndices.isNotEmpty) {
          expect(unknownIndices.last, lessThan(knownIndices.first));
        }
      });

      test('should sort by frequency descending within same known status', () async {
        final result = await service.process(
          rawText: 'alpha beta beta gamma gamma gamma delta delta delta delta',
          knownWords: {'alpha'},
        );
        
        // Find the unknown words section
        final unknownWords =
            result.words.where((w) => !w.isKnown).toList();
        
        // Within unknown words, should be sorted by frequency descending
        for (int i = 0; i < unknownWords.length - 1; i++) {
          expect(
            unknownWords[i].totalCount,
            greaterThanOrEqualTo(unknownWords[i + 1].totalCount),
          );
        }
      });
    });

    group('Known word marking', () {
      test('should mark known words correctly', () async {
        final result = await service.process(
          rawText: 'hello world flutter',
          knownWords: {'hello', 'flutter'},
        );
        
        final hello = result.words.firstWhere((w) => w.wordText == 'hello');
        expect(hello.isKnown, true);
        
        final world = result.words.firstWhere((w) => w.wordText == 'world');
        expect(world.isKnown, false);
        
        final flutter = result.words.firstWhere((w) => w.wordText == 'flutter');
        expect(flutter.isKnown, true);
      });

      test('should handle empty known words set', () async {
        final result = await service.process(
          rawText: 'hello world flutter',
          knownWords: {},
        );
        
        // All words should be unknown
        expect(result.words.every((w) => !w.isKnown), true);
      });

      test('should handle all words known', () async {
        final result = await service.process(
          rawText: 'hello world flutter',
          knownWords: {'hello', 'world', 'flutter'},
        );
        
        // All words should be known
        expect(result.words.every((w) => w.isKnown), true);
      });
    });

    group('Stop words filtering', () {
      test('should filter common stop words', () async {
        final result = await service.process(
          rawText:
              'the quick brown fox jumps over the lazy dog the the the',
          knownWords: {},
        );
        
        // Stop words should not appear
        expect(result.words.any((w) => w.wordText == 'the'), false);
        expect(result.words.any((w) => w.wordText == 'over'), false);
        
        // Content words should appear
        expect(result.words.any((w) => w.wordText == 'quick'), true);
        expect(result.words.any((w) => w.wordText == 'brown'), true);
        expect(result.words.any((w) => w.wordText == 'fox'), true);
      });

      test('should filter single-letter words', () async {
        final result = await service.process(
          rawText: 'I a x hello world',
          knownWords: {},
        );
        
        // Single letters should be filtered
        expect(result.words.any((w) => w.wordText.length < 2), false);
        
        // Multi-letter words should remain
        expect(result.words.any((w) => w.wordText == 'hello'), true);
        expect(result.words.any((w) => w.wordText == 'world'), true);
      });

      test('should maintain totalWords count including stop words', () async {
        final result = await service.process(
          rawText: 'the quick brown fox',
          knownWords: {},
        );
        
        // totalWords counts all words matched by regex (including stop words)
        expect(result.summary.totalWords, 4);
        // uniqueWords counts unique filtered words (excluding stop words)
        expect(result.summary.uniqueWords, 3);
      });
    });

    group('Contractions', () {
      test('should handle contractions as single words', () async {
        final result = await service.process(
          rawText: "don't can't won't shouldn't couldn't",
          knownWords: {},
        );
        
        expect(result.words.any((w) => w.wordText == "don't"), true);
        expect(result.words.any((w) => w.wordText == "can't"), true);
        expect(result.words.any((w) => w.wordText == "won't"), true);
      });

      test('should count contractions with correct frequency', () async {
        final result = await service.process(
          rawText: "don't don't can't don't",
          knownWords: {},
        );
        
        final dont = result.words.firstWhere((w) => w.wordText == "don't");
        expect(dont.totalCount, 3);
      });
    });

    group('Special characters and punctuation', () {
      test('should strip punctuation from words', () async {
        final result = await service.process(
          rawText: 'Hello, world! How are you? Fine. Great!',
          knownWords: {},
        );
        
        // Punctuation should not be part of word text
        expect(
          result.words.every((w) =>
              !w.wordText.contains(',') &&
              !w.wordText.contains('!') &&
              !w.wordText.contains('?') &&
              !w.wordText.contains('.')),
          true,
        );
        
        // Words should be extracted (with stop words filtered)
        expect(result.words.any((w) => w.wordText == 'hello'), true);
        expect(result.words.any((w) => w.wordText == 'world'), true);
      });

      test('should not match pure numbers', () async {
        final result = await service.process(
          rawText: 'version 123 release 456 flutter',
          knownWords: {},
        );
        
        // Pure numbers should not be words
        expect(result.words.any((w) => w.wordText == '123'), false);
        expect(result.words.any((w) => w.wordText == '456'), false);
        
        // Letters should be matched
        expect(result.words.any((w) => w.wordText == 'version'), true);
        expect(result.words.any((w) => w.wordText == 'release'), true);
      });

      test('should not match hyphenated words incorrectly', () async {
        final result = await service.process(
          rawText: 'well-known e-mail co-operation',
          knownWords: {},
        );
        
        // Hyphenated words should be matched as separate words or filtered
        // based on regex: \b[a-zA-Z]{2,}(?:'[a-zA-Z]+)?\b
        // This regex does NOT match hyphens, only contractions
        expect(result.words.isNotEmpty, true);
      });
    });

    group('Edge cases', () {
      test('should handle empty input', () async {
        final result = await service.process(
          rawText: '',
          knownWords: {},
        );
        
        expect(result.words, isEmpty);
        expect(result.summary.totalWords, 0);
        expect(result.summary.uniqueWords, 0);
        expect(result.summary.newWords, 0);
      });

      test('should handle whitespace-only input', () async {
        final result = await service.process(
          rawText: '   \n\t  ',
          knownWords: {},
        );
        
        expect(result.words, isEmpty);
        expect(result.summary.totalWords, 0);
      });

      test('should handle input with only stop words', () async {
        final result = await service.process(
          rawText: 'the and but or is are',
          knownWords: {},
        );
        
        // All words are stop words, so should be filtered out
        expect(result.words, isEmpty);
        expect(result.summary.uniqueWords, 0);
      });

      test('should handle input with only single letters', () async {
        final result = await service.process(
          rawText: 'a b c d e f g',
          knownWords: {},
        );
        
        // All are single letters, should be filtered
        expect(result.words, isEmpty);
      });

      test('should handle very long input', () async {
        final longText = 'word ' * 1000;
        final result = await service.process(
          rawText: longText,
          knownWords: {},
        );
        
        // Should process without issues
        expect(result.words.length, 1);
        expect(result.words.first.wordText, 'word');
        expect(result.words.first.totalCount, 1000);
      });
    });

    group('Summary counts', () {
      test('should provide correct summary', () async {
        final result = await service.process(
          rawText: 'hello world hello flutter world hello',
          knownWords: {'hello'},
        );
        
        expect(result.summary.totalWords, 6);
        expect(result.summary.uniqueWords, 3); // hello, world, flutter
        expect(result.summary.newWords, 2); // world, flutter (not hello)
      });

      test('should count newWords correctly (unknown unique words)', () async {
        final result = await service.process(
          rawText: 'alpha beta beta gamma gamma gamma',
          knownWords: {'alpha'},
        );
        
        // newWords = unknown unique words
        // alpha is known, beta and gamma are unknown
        expect(result.summary.newWords, 2);
      });

      test('should count emptySummary for empty input', () async {
        final result = await service.process(
          rawText: '',
          knownWords: {},
        );
        
        expect(result.summary.totalWords, 0);
        expect(result.summary.uniqueWords, 0);
        expect(result.summary.newWords, 0);
      });
    });

    group('Real-world scenarios', () {
      test('should process typical script correctly', () async {
        const script = '''
        Flutter is a great framework. Flutter makes development fun.
        Learning Flutter helps developers build awesome apps quickly.
        ''';
        
        final result = await service.process(
          rawText: script,
          knownWords: {'flutter', 'development'},
        );
        
        // Flutter and development should be marked as known
        final flutter = result.words
            .firstWhere((w) => w.wordText == 'flutter', orElse: () => const ProcessedWord(wordText: '', totalCount: 0, isKnown: false));
        if (flutter.wordText.isNotEmpty) {
          expect(flutter.isKnown, true);
        }
        
        // Should have multiple unique words
        expect(result.summary.uniqueWords, greaterThan(5));
      });

      test('should handle mixed case and contractions', () async {
        const script = "I can't believe it's working! That's amazing!";
        
        final result = await service.process(
          rawText: script,
          knownWords: {},
        );
        
        // Contractions should be preserved
        expect(
          result.words.any((w) => w.wordText.contains("'")),
          true,
        );
      });
    });
  });
}
