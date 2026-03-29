import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/toggle_known_word.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockWordRepository mockRepository;
  late ToggleKnownWord useCase;

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = ToggleKnownWord(mockRepository);
  });

  group('ToggleKnownWord', () {
    const testWordText = 'flutter';
    const testUserId = 'user-1';

    test('should call repository.toggleKnown with correct parameters', () async {
      // Arrange
      when(() => mockRepository.toggleKnown(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(testWordText, userId: testUserId);

      // Assert
      verify(() => mockRepository.toggleKnown(testWordText, userId: testUserId)).called(1);
    });

    test('should call repository.toggleKnown with null userId when not provided', () async {
      // Arrange
      when(() => mockRepository.toggleKnown(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(testWordText);

      // Assert
      verify(() => mockRepository.toggleKnown(testWordText, userId: null)).called(1);
    });

    test('should return Right(null) on success', () async {
      // Arrange
      when(() => mockRepository.toggleKnown(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testWordText, userId: testUserId);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('Failed to toggle word');
      when(() => mockRepository.toggleKnown(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testWordText, userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should handle different word texts', () async {
      // Arrange
      const otherWord = 'dart';
      when(() => mockRepository.toggleKnown(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(otherWord, userId: testUserId);

      // Assert
      verify(() => mockRepository.toggleKnown(otherWord, userId: testUserId)).called(1);
    });
  });
}
