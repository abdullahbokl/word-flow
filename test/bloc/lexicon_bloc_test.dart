import 'package:flutter_test/flutter_test.dart';
import 'package:lexitrack/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_repository.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/add_word_manually.dart';
import 'package:mocktail/mocktail.dart';

class MockLexiconRepository extends Mock implements LexiconRepository {}

void main() {
  group('AddWordManually', () {
    test('returns validation failure when text is empty', () async {
      final repository = MockLexiconRepository();
      final usecase = AddWordManually(repository);

      final result = await usecase('').run();
      expect(result.isLeft(), true);
    });

    test('returns validation failure when text is too short', () async {
      final repository = MockLexiconRepository();
      final usecase = AddWordManually(repository);

      final result = await usecase('a').run();
      expect(result.isLeft(), true);
    });
  });

  group('LexiconStats', () {
    test('empty stats has correct values', () {
      const stats = LexiconStats.empty();
      expect(stats.total, 0);
      expect(stats.known, 0);
      expect(stats.unknown, 0);
    });
  });
}
