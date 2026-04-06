import 'package:flutter_test/flutter_test.dart';
import 'package:lexitrack/core/utils/text_processor.dart';

void main() {
  group('TextProcessor._tokenizeAndCount via process()', () {
    test('returns empty map for empty input', () async {
      final result = await TextProcessor.process('');
      expect(result, isEmpty);
    });

    test('returns empty map for whitespace-only input', () async {
      final result = await TextProcessor.process('   \n\t  ');
      expect(result, isEmpty);
    });

    test('counts word frequencies correctly', () async {
      final result = await TextProcessor.process(
        'the cat sat on the mat',
      );
      expect(result['the'], 2);
      expect(result['cat'], 1);
      expect(result['mat'], 1);
    });

    test('normalizes to lowercase', () async {
      final result = await TextProcessor.process('Hello WORLD hello');
      expect(result['hello'], 2);
      expect(result['world'], 1);
    });

    test('removes punctuation', () async {
      final result = await TextProcessor.process('hello, world!');
      expect(result['hello'], 1);
      expect(result['world'], 1);
    });

    test('preserves apostrophes in contractions', () async {
      final result = await TextProcessor.process("don't can't");
      expect(result["don't"], 1);
      expect(result["can't"], 1);
    });

    test('removes surrounding apostrophes', () async {
      final result = await TextProcessor.process("'hello'");
      expect(result['hello'], 1);
    });

    test('filters tokens without letters', () async {
      final result = await TextProcessor.process('123 456 hello');
      expect(result['hello'], 1);
      expect(result.containsKey('123'), false);
    });

    test('removes URLs', () async {
      final result = await TextProcessor.process(
        'check https://example.com please',
      );
      expect(result['check'], 1);
      expect(result['please'], 1);
      expect(result.containsKey('example'), false);
    });
  });

  group('TextProcessor.totalTokenCount', () {
    test('returns 0 for empty map', () {
      expect(TextProcessor.totalTokenCount({}), 0);
    });

    test('sums all frequencies', () {
      expect(
        TextProcessor.totalTokenCount({'a': 2, 'b': 3}),
        5,
      );
    });
  });
}
