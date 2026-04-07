import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_entity.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_repository.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/add_word_manually.dart';

class MockLexiconRepository extends Mock implements LexiconRepository {}

void main() {
  late AddWordManually usecase;
  late MockLexiconRepository repository;

  setUp(() {
    repository = MockLexiconRepository();
    usecase = AddWordManually(repository);
  });

  group('AddWordManually', () {
    test('returns validation failure when text is empty', () async {
      final result = await usecase('').run();
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Expected left'),
      );
    });

    test('returns validation failure when text is less than 2 chars', () async {
      final result = await usecase('a').run();
      expect(result.isLeft(), true);
    });

    test('delegates to repository when valid', () async {
      final now = DateTime(2024);
      final word = WordEntity(
        id: 1,
        text: 'hello',
        frequency: 0,
        isKnown: false,
        createdAt: now,
        updatedAt: now,
        meaning: null,
        description: null,
      );
      when(() => repository.addWord(any())).thenAnswer(
        (_) => TaskEither.right(word),
      );

      final result = await usecase('hello').run();

      expect(result.isRight(), true);
      verify(() => repository.addWord('hello')).called(1);
    });

    test('normalizes text to lowercase', () async {
      final now = DateTime(2024);
      final word = WordEntity(
        id: 1,
        text: 'hello',
        frequency: 0,
        isKnown: false,
        createdAt: now,
        updatedAt: now,
        meaning: null,
        description: null,
      );
      when(() => repository.addWord(any())).thenAnswer(
        (_) => TaskEither.right(word),
      );

      await usecase('HELLO').run();

      verify(() => repository.addWord('hello')).called(1);
    });
  });
}
