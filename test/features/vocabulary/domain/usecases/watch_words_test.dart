import 'package:word_flow/core/usecases/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_words.dart';

import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/mock_data.dart';

void main() {
  late MockWordRepository mockRepository;
  late WatchWords useCase;

  setUpAll(() {
    registerFallbackValue(testWord);
  });

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = WatchWords(mockRepository);
  });

  group('WatchWords', () {
    const testUserId = 'user-1';

    test('should call repository.watchWords with correct userId', () {
      // Arrange
      when(
        () => mockRepository.watchWords(userId: any(named: 'userId')),
      ).thenAnswer((_) => Stream.value(testWordList));

      // Act
      useCase(const UserIdParams(userId: testUserId));

      // Assert
      verify(() => mockRepository.watchWords(userId: testUserId)).called(1);
    });

    test(
      'should call repository.watchWords with null userId when not provided',
      () {
        // Arrange
        when(
          () => mockRepository.watchWords(userId: any(named: 'userId')),
        ).thenAnswer((_) => Stream.value(testWordList));

        // Act
        useCase(const UserIdParams());

        // Assert
        verify(() => mockRepository.watchWords(userId: null)).called(1);
      },
    );

    test('should return a stream from repository', () {
      // Arrange
      when(
        () => mockRepository.watchWords(userId: any(named: 'userId')),
      ).thenAnswer((_) => Stream.value(testWordList));

      // Act
      final stream = useCase(const UserIdParams(userId: testUserId));

      // Assert
      expect(stream, isA<Stream<Either<Failure, List<WordEntity>>>>());
    });

    test('should emit word list from repository stream', () {
      // Arrange
      when(
        () => mockRepository.watchWords(userId: any(named: 'userId')),
      ).thenAnswer((_) => Stream.value(testWordList));

      // Act
      final stream = useCase(const UserIdParams(userId: testUserId));

      // Assert
      expectLater(
        stream,
        emits(Right<Failure, List<WordEntity>>(testWordList)),
      );
    });

    test('should emit empty list when no words', () {
      // Arrange
      when(
        () => mockRepository.watchWords(userId: any(named: 'userId')),
      ).thenAnswer((_) => Stream.value(testEmptyWordList));

      // Act
      final stream = useCase(const UserIdParams(userId: testUserId));

      // Assert
      expectLater(
        stream,
        emits(Right<Failure, List<WordEntity>>(testEmptyWordList)),
      );
    });

    test('should emit multiple word lists over time', () {
      final singleWordList = [testWord];

      // Arrange
      when(
        () => mockRepository.watchWords(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          testEmptyWordList,
          singleWordList,
          testWordList,
        ]),
      );

      // Act
      final stream = useCase(const UserIdParams(userId: testUserId));

      // Assert
      expectLater(
        stream,
        emitsInOrder([
          Right<Failure, List<WordEntity>>(testEmptyWordList),
          Right<Failure, List<WordEntity>>(singleWordList),
          Right<Failure, List<WordEntity>>(testWordList),
        ]),
      );
    });

    test('should propagate errors from repository stream', () {
      // Arrange
      final error = Exception('Stream error');
      when(
        () => mockRepository.watchWords(userId: any(named: 'userId')),
      ).thenAnswer((_) => Stream.error(error));

      // Act
      final stream = useCase(const UserIdParams(userId: testUserId));

      // Assert
      expectLater(stream, emitsError(error));
    });
  });
}
