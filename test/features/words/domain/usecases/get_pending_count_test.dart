import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/usecases/get_pending_count.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockSyncRepository mockRepository;
  late GetPendingCount useCase;

  setUp(() {
    mockRepository = MockSyncRepository();
    useCase = GetPendingCount(mockRepository);
  });

  group('GetPendingCount', () {
    const testCount = 7;

    test('should call repository.getPendingCount', () async {
      // Arrange
      when(() => mockRepository.getPendingCount())
          .thenAnswer((_) async => const Right(testCount));

      // Act
      await useCase();

      // Assert
      verify(() => mockRepository.getPendingCount()).called(1);
    });

    test('should return Right(count) on success', () async {
      // Arrange
      when(() => mockRepository.getPendingCount())
          .thenAnswer((_) async => const Right(testCount));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => 0), testCount);
    });

    test('should return Right(0) when no pending words', () async {
      // Arrange
      when(() => mockRepository.getPendingCount())
          .thenAnswer((_) async => const Right(0));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => -1), 0);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = SyncFailure('Failed to get pending count');
      when(() => mockRepository.getPendingCount())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
