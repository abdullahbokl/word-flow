import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/clear_local_words.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockWordRepository mockRepository;
  late ClearLocalWords useCase;

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = ClearLocalWords(mockRepository);
  });

  group('ClearLocalWords', () {
    const testUserId = 'user-1';

    test('should call repository.clearLocalWords with correct userId', () async {
      // Arrange
      when(() => mockRepository.clearLocalWords(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(const ClearLocalWordsParams(userId: testUserId));

      // Assert
      verify(() => mockRepository.clearLocalWords(testUserId)).called(1);
    });

    test('should return Right(null) on success', () async {
      // Arrange
      when(() => mockRepository.clearLocalWords(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const ClearLocalWordsParams(userId: testUserId));

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('Failed to clear words');
      when(() => mockRepository.clearLocalWords(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const ClearLocalWordsParams(userId: testUserId));

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
