import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/lexicon/domain/commands/word_commands.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_repository.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/add_word_manually.dart';
import 'package:mocktail/mocktail.dart';

class MockLexiconRepository extends Mock implements LexiconRepository {}

void main() {
  late AddWordManually usecase;
  late MockLexiconRepository repository;

  setUpAll(() {
    registerFallbackValue(const AddWordCommand(text: ''));
  });

  setUp(() {
    repository = MockLexiconRepository();
    usecase = AddWordManually(repository);
  });

  group('AddWordManually', () {
    test('returns validation failure when text is empty', () async {
      final result = await usecase(const AddWordCommand(text: '')).run();
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Expected left'),
      );
    });

    test('returns validation failure when text is less than 2 chars', () async {
      final result = await usecase(const AddWordCommand(text: 'a')).run();
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

      final result = await usecase(const AddWordCommand(text: 'hello')).run();

      expect(result.isRight(), true);
      verify(() => repository.addWord(const AddWordCommand(text: 'hello'))).called(1);
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

      await usecase(const AddWordCommand(text: 'HELLO')).run();

      verify(() => repository.addWord(const AddWordCommand(text: 'hello'))).called(1);
    });
  });
}
