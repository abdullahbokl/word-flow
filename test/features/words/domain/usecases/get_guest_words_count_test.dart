import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/usecases/get_guest_words_count.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockWordRepository mockRepository;
  late GetGuestWordsCount useCase;

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = GetGuestWordsCount(mockRepository);
  });

  group('GetGuestWordsCount', () {
    const testCount = 10;

    test('should call repository.getGuestWordsCount', () async {
      // Arrange
      when(() => mockRepository.getGuestWordsCount())
          .thenAnswer((_) async => const Right(testCount));

      // Act
      await useCase();

      // Assert
      verify(() => mockRepository.getGuestWordsCount()).called(1);
    });

    test('should return Right(count) on success', () async {
      // Arrange
      when(() => mockRepository.getGuestWordsCount())
          .thenAnswer((_) async => const Right(testCount));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => 0), testCount);
    });

    test('should return Right(0) when no guest words', () async {
      // Arrange
      when(() => mockRepository.getGuestWordsCount())
          .thenAnswer((_) async => const Right(0));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => -1), 0);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('Failed to count guest words');
      when(() => mockRepository.getGuestWordsCount())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
