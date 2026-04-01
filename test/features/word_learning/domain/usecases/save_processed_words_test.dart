import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/word_learning/domain/usecases/save_processed_words.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';

class MockWordRepository extends Mock implements WordRepository {}

void main() {
  late SaveProcessedWords useCase;
  late MockWordRepository mockRepository;

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = SaveProcessedWords(mockRepository);

    // Register fallback for mocktail
    registerFallbackValue(<WordEntity>[]);
  });

  const tUserId = 'user-123';

  group('SaveProcessedWords', () {
    test(
      'should return Right(null) and do nothing when word list is empty',
      () async {
        // act
        final result = await useCase([], userId: tUserId);

        // assert
        expect(result, const Right(null));
        verifyNever(() => mockRepository.saveWords(any()));
      },
    );

    test(
      'should properly map ProcessedWord entries to WordEntity and call repository',
      () async {
        // arrange
        final tProcessed = [
          const ProcessedWord(wordText: 'hello', totalCount: 5, isKnown: true),
          const ProcessedWord(wordText: 'world', totalCount: 2, isKnown: false),
        ];

        when(
          () => mockRepository.saveWords(any()),
        ).thenAnswer((_) async => const Right(null));

        // act
        final result = await useCase(tProcessed, userId: tUserId);

        // assert
        expect(result.isRight(), true);

        // Capture the list passed to repository
        final captured =
            verify(() => mockRepository.saveWords(captureAny())).captured.first
                as List<WordEntity>;

        expect(captured.length, 2);

        // Verify mapping
        final hello = captured.firstWhere((w) => w.wordText == 'hello');
        expect(hello.totalCount, 5);
        expect(hello.isKnown, true);
        expect(hello.userId, tUserId);
        expect(hello.id, isNotEmpty); // Random UUID generated

        final world = captured.firstWhere((w) => w.wordText == 'world');
        expect(world.totalCount, 2);
        expect(world.isKnown, false);
        expect(world.userId, tUserId);
      },
    );

    test(
      'should propagate repository failure wrapped in Left(DatabaseFailure)',
      () async {
        // arrange
        final tProcessed = [
          const ProcessedWord(wordText: 'hello', totalCount: 5, isKnown: true),
        ];
        when(
          () => mockRepository.saveWords(any()),
        ).thenAnswer((_) async => const Left(DatabaseFailure('save error')));

        // act
        final result = await useCase(tProcessed, userId: tUserId);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<DatabaseFailure>()),
          (_) => fail('should be Left'),
        );
      },
    );
  });
}
