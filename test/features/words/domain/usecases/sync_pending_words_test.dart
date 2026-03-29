import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/usecases/sync_pending_words.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockSyncRepository mockRepository;
  late SyncPendingWords useCase;

  setUp(() {
    mockRepository = MockSyncRepository();
    useCase = SyncPendingWords(mockRepository);
  });

  group('SyncPendingWords', () {
    const testSyncedCount = 5;

    test('should call repository.syncPendingWords', () async {
      // Arrange
      when(() => mockRepository.syncPendingWords())
          .thenAnswer((_) async => const Right(testSyncedCount));

      // Act
      await useCase();

      // Assert
      verify(() => mockRepository.syncPendingWords()).called(1);
    });

    test('should return Right(count) on success', () async {
      // Arrange
      when(() => mockRepository.syncPendingWords())
          .thenAnswer((_) async => const Right(testSyncedCount));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => 0), testSyncedCount);
    });

    test('should return Right(0) when nothing to sync', () async {
      // Arrange
      when(() => mockRepository.syncPendingWords())
          .thenAnswer((_) async => const Right(0));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => -1), 0);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = SyncFailure('Failed to sync pending words');
      when(() => mockRepository.syncPendingWords())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return Left(Failure) on server error', () async {
      // Arrange
      const failure = ServerFailure('Server error during sync');
      when(() => mockRepository.syncPendingWords())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
