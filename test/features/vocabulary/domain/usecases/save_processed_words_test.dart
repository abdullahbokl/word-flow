import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/word_learning/domain/usecases/save_processed_words.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mock_data.dart';

void main() {
  late MockWordRepository mockRepository;
  late SaveProcessedWords useCase;

  setUpAll(() {
    registerFallbackValue(testWord);
  });

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = SaveProcessedWords(mockRepository);
  });

  group('SaveProcessedWords', () {
    const testUserId = 'user-1';
    final testProcessedWords = [testProcessedWord, testProcessedKnownWord];

    test('should call repository.saveWords after mapping processed words', () async {
      // Arrange
      when(() => mockRepository.saveWords(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(testProcessedWords, userId: testUserId);

      // Assert
      verify(() => mockRepository.saveWords(any())).called(1);
    });

    test('should map processed words to WordEntity objects with correct properties', () async {
      // Arrange
      when(() => mockRepository.saveWords(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(testProcessedWords, userId: testUserId);

      // Assert
      final capturedWords = verify(() => mockRepository.saveWords(captureAny()))
          .captured[0] as List<WordEntity>;
      expect(capturedWords, hasLength(2));
      expect(capturedWords[0].wordText, testProcessedWord.wordText);
      expect(capturedWords[0].totalCount, testProcessedWord.totalCount);
      expect(capturedWords[0].isKnown, testProcessedWord.isKnown);
    });

    test('should include userId in mapped WordEntity objects', () async {
      // Arrange
      when(() => mockRepository.saveWords(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(testProcessedWords, userId: testUserId);

      // Assert
      final capturedWords = verify(() => mockRepository.saveWords(captureAny()))
          .captured[0] as List<WordEntity>;
      expect(capturedWords[0].userId, testUserId);
    });

    test('should return Right(null) on success', () async {
      // Arrange
      when(() => mockRepository.saveWords(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testProcessedWords, userId: testUserId);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return Left(Failure) when repository fails', () async {
      // Arrange
      const failure = DatabaseFailure('Failed to save words');
      when(() => mockRepository.saveWords(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testProcessedWords, userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should handle empty list of processed words', () async {
      // Arrange
      when(() => mockRepository.saveWords(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase([], userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveWords(any())).called(1);
    });
  });
}
