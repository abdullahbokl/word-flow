import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/usecases/process_script.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mock_data.dart';

void main() {
  late MockWordRepository mockRepository;
  late MockTextAnalysisService mockService;
  late ProcessScript useCase;

  setUpAll(() {
    registerFallbackValue(testScriptAnalysis);
  });

  setUp(() {
    mockRepository = MockWordRepository();
    mockService = MockTextAnalysisService();
    useCase = ProcessScript(mockRepository, mockService);
  });

  group('ProcessScript', () {
    const testRawText = 'Flutter is great';
    const testUserId = 'user-1';
    const testKnownTexts = ['flutter', 'is'];

    test('should get known words from repository first', () async {
      // Arrange
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(testKnownTexts));
      when(() => mockService.process(
            rawText: any(named: 'rawText'),
            knownWords: any(named: 'knownWords'),
          )).thenAnswer((_) async => testScriptAnalysis);

      // Act
      await useCase(testRawText, userId: testUserId);

      // Assert
      verify(() => mockRepository.getKnownWordTexts(userId: testUserId)).called(1);
    });

    test('should call text analysis service with raw text and known words', () async {
      // Arrange
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(testKnownTexts));
      when(() => mockService.process(
            rawText: any(named: 'rawText'),
            knownWords: any(named: 'knownWords'),
          )).thenAnswer((_) async => testScriptAnalysis);

      // Act
      await useCase(testRawText, userId: testUserId);

      // Assert
      verify(() => mockService.process(
            rawText: testRawText,
            knownWords: {'flutter', 'is'},
          )).called(1);
    });

    test('should return Right(analysis) on success', () async {
      // Arrange
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(testKnownTexts));
      when(() => mockService.process(
            rawText: any(named: 'rawText'),
            knownWords: any(named: 'knownWords'),
          )).thenAnswer((_) async => testScriptAnalysis);

      // Act
      final result = await useCase(testRawText, userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => testScriptAnalysisEmpty), testScriptAnalysis);
    });

    test('should use empty set when repository returns failure', () async {
      // Arrange
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Left(DatabaseFailure('Error')));
      when(() => mockService.process(
            rawText: any(named: 'rawText'),
            knownWords: any(named: 'knownWords'),
          )).thenAnswer((_) async => testScriptAnalysis);

      // Act
      await useCase(testRawText, userId: testUserId);

      // Assert
      verify(() => mockService.process(
            rawText: testRawText,
            knownWords: <String>{},
          )).called(1);
    });

    test('should return Left(ProcessingFailure) on service exception', () async {
      // Arrange
      when(() => mockRepository.getKnownWordTexts(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(testKnownTexts));
      when(() => mockService.process(
            rawText: any(named: 'rawText'),
            knownWords: any(named: 'knownWords'),
          )).thenThrow(Exception('Processing error'));

      // Act
      final result = await useCase(testRawText, userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ProcessingFailure>()),
        (_) => fail('Expected left'),
      );
    });
  });
}
