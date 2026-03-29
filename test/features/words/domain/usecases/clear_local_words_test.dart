import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/usecases/clear_local_words.dart';

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
      when(() => mockRepository.clearLocalWords(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(userId: testUserId);

      // Assert
      verify(() => mockRepository.clearLocalWords(userId: testUserId)).called(1);
    });

    test('should call repository.clearLocalWords with null userId when not provided', () async {
      // Arrange
      when(() => mockRepository.clearLocalWords(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase();

      // Assert
      verify(() => mockRepository.clearLocalWords(userId: null)).called(1);
    });

    test('should return Right(null) on success', () async {
      // Arrange
      when(() => mockRepository.clearLocalWords(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      final failure = const DatabaseFailure('Failed to clear words');
      when(() => mockRepository.clearLocalWords(userId: any(named: 'userId')))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
