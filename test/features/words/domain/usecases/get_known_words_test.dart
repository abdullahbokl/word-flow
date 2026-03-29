import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/usecases/get_known_words.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mock_data.dart';

void main() {
  late MockWordRepository mockRepository;
  late GetKnownWords useCase;

  setUpAll(() {
    registerFallbackValue(testWord);
  });

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = GetKnownWords(mockRepository);
  });

  group('GetKnownWords', () {
    const testUserId = 'user-1';

    test('should call repository.getKnownWords with correct userId', () async {
      // Arrange
      when(() => mockRepository.getKnownWords(userId: any(named: 'userId')))
          .thenAnswer((_) async => Right(testWordList));

      // Act
      await useCase(userId: testUserId);

      // Assert
      verify(() => mockRepository.getKnownWords(userId: testUserId)).called(1);
    });

    test('should call repository.getKnownWords with null userId when not provided', () async {
      // Arrange
      when(() => mockRepository.getKnownWords(userId: any(named: 'userId')))
          .thenAnswer((_) async => Right(testWordList));

      // Act
      await useCase();

      // Assert
      verify(() => mockRepository.getKnownWords(userId: null)).called(1);
    });

    test('should return Right(wordList) on success', () async {
      // Arrange
      when(() => mockRepository.getKnownWords(userId: any(named: 'userId')))
          .thenAnswer((_) async => Right(testWordList));

      // Act
      final result = await useCase(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => []), testWordList);
    });

    test('should return Right(emptyList) when no words found', () async {
      // Arrange
      when(() => mockRepository.getKnownWords(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => []), isEmpty);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('Failed to fetch known words');
      when(() => mockRepository.getKnownWords(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
