import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/update_word.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mock_data.dart';

void main() {
  late MockWordRepository mockRepository;
  late UpdateWord useCase;

  setUpAll(() {
    registerFallbackValue(testWord);
  });

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = UpdateWord(mockRepository);
  });

  group('UpdateWord', () {
    test('should call repository.updateWord with correct word', () async {
      // Arrange
      when(() => mockRepository.updateWord(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(testWord);

      // Assert
      verify(() => mockRepository.updateWord(testWord)).called(1);
    });

    test('should return Right(null) on success', () async {
      // Arrange
      when(() => mockRepository.updateWord(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testWord);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Right(null) when updating known word', () async {
      // Arrange
      when(() => mockRepository.updateWord(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testKnownWord);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.updateWord(testKnownWord)).called(1);
    });

    test('should return Right(null) when updating guest word', () async {
      // Arrange
      when(() => mockRepository.updateWord(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testGuestWord);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.updateWord(testGuestWord)).called(1);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('Failed to update word');
      when(() => mockRepository.updateWord(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testWord);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
