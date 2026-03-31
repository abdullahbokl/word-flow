import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/toggle_known_word.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

class MockWordRepository extends Mock implements WordRepository {}

void main() {
  late ToggleKnownWord useCase;
  late MockWordRepository mockRepository;

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = ToggleKnownWord(mockRepository);
  });

  const tWordText = 'hello';
  const tUserId = 'user-123';

  group('ToggleKnownWord', () {
    test(
      'should return Right(null) when call to repository is successful',
      () async {
        // arrange
        when(
          () => mockRepository.toggleKnown(any(), userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Right(null));

        // act
        final result = await useCase(tWordText, userId: tUserId);

        // assert
        expect(result, const Right(null));
        verify(
          () => mockRepository.toggleKnown(tWordText, userId: tUserId),
        ).called(1);
      },
    );

    test(
      'should return Left(DatabaseFailure) when call to repository fails',
      () async {
        // arrange
        const tFailure = DatabaseFailure('database error');
        when(
          () => mockRepository.toggleKnown(any(), userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Left(tFailure));

        // act
        final result = await useCase(tWordText, userId: tUserId);

        // assert
        expect(result, const Left(tFailure));
      },
    );

    test(
      'should successfuly toggle with null userId (guest mode) and pass to repository',
      () async {
        // arrange
        when(
          () => mockRepository.toggleKnown(any(), userId: null),
        ).thenAnswer((_) async => const Right(null));

        // act
        final result = await useCase(tWordText, userId: null);

        // assert
        expect(result, const Right(null));
        verify(
          () => mockRepository.toggleKnown(tWordText, userId: null),
        ).called(1);
      },
    );
  });
}
