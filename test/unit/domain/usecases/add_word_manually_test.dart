import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../lib/core/error/failures.dart';
import '../../../lib/features/lexicon/domain/entities/word_entity.dart';
import '../../../lib/features/lexicon/domain/repositories/lexicon_repository.dart';
import '../../../lib/features/lexicon/domain/usecases/add_word_manually.dart';

class MockLexiconRepository extends Mock implements LexiconRepository {}

void main() {
  late AddWordManually usecase;
  late MockLexiconRepository repository;

  setUp(() {
    repository = MockLexiconRepository();
    usecase = AddWordManually(repository);
  });

  group('AddWordManually', () {
    test('returns validation failure when text is empty', () {
      final result = usecase.call('');
      expect(result.isLeft(), true);
      expect((result as Left).value, isA<ValidationFailure>());
    });

    test('returns validation failure when text is less than 2 chars', () {
      final result = usecase.call('a');
      expect(result.isLeft(), true);
    });

    test('delegates to repository when valid', () {
      when(() => repository.addWord(any())).thenAnswer(
        (_) => TaskEither.right(
          WordEntity(
            id: 1,
            text: 'hello',
            frequency: 0,
            isKnown: false,
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
            meaning: null,
            description: null,
          ),
        ),
      );

      final result = usecase.call('hello');

      expect(result.isRight(), true);
      verify(() => repository.addWord('hello')).called(1);
    });
  });
}
