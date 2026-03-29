import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/usecases/get_known_word_texts.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockWordRepository mockRepository;
  late GetKnownWordTexts useCase;

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = GetKnownWordTexts(mockRepository);
  });

  group('GetKnownWordTexts', () {
    const testUserId = 'user-1';
    const testTexts = ['flutter', 'dart', 'widget'];

    test('should call repository.getKnownWordTexts with correct userId', () async {
      // Arrange
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(testTexts));

      // Act
      await useCase(userId: testUserId);

      // Assert
      verify(() => mockRepository.getKnownWordTexts(userId: testUserId)).called(1);
    });

    test('should call repository.getKnownWordTexts with null userId when not provided', () async {
      // Arrange
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(testTexts));

      // Act
      await useCase();

      // Assert
      verify(() => mockRepository.getKnownWordTexts(userId: null)).called(1);
    });

    test('should return Right(textsList) on success', () async {
      // Arrange
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(testTexts));

      // Act
      final result = await useCase(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => []), testTexts);
    });

    test('should return Right(emptyList) when no known words', () async {
      // Arrange
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => []), isEmpty);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      final failure = const DatabaseFailure('Failed to fetch known word texts');
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
