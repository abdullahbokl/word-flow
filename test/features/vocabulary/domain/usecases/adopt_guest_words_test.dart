import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/adopt_guest_words.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockWordRepository mockRepository;
  late AdoptGuestWords useCase;

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = AdoptGuestWords(mockRepository);
  });

  group('AdoptGuestWords', () {
    const testUserId = 'user-1';
    const testCount = 5;

    test(
      'should call repository.adoptGuestWords with correct userId',
      () async {
        // Arrange
        when(
          () => mockRepository.adoptGuestWords(any()),
        ).thenAnswer((_) async => const Right(testCount));

        // Act
        await useCase(testUserId);

        // Assert
        verify(() => mockRepository.adoptGuestWords(testUserId)).called(1);
      },
    );

    test('should return Right(count) on success', () async {
      // Arrange
      when(
        () => mockRepository.adoptGuestWords(any()),
      ).thenAnswer((_) async => const Right(testCount));

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => 0), testCount);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = ServerFailure('Adoption failed');
      when(
        () => mockRepository.adoptGuestWords(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
