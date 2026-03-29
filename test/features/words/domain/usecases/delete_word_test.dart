import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/usecases/delete_word.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockWordRepository mockRepository;
  late DeleteWord useCase;

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = DeleteWord(mockRepository);
  });

  group('DeleteWord', () {
    const testWordId = 'word-1';
    const testUserId = 'user-1';

    test('should call repository.deleteWord with correct parameters', () async {
      // Arrange
      when(() => mockRepository.deleteWord(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(testWordId, userId: testUserId);

      // Assert
      verify(() => mockRepository.deleteWord(testWordId, userId: testUserId)).called(1);
    });

    test('should call repository.deleteWord with null userId when not provided', () async {
      // Arrange
      when(() => mockRepository.deleteWord(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(testWordId);

      // Assert
      verify(() => mockRepository.deleteWord(testWordId, userId: null)).called(1);
    });

    test('should return Right(null) on success', () async {
      // Arrange
      when(() => mockRepository.deleteWord(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testWordId, userId: testUserId);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('Failed to delete word');
      when(() => mockRepository.deleteWord(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testWordId, userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
