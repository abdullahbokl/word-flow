import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/features/words/domain/usecases/watch_words.dart';

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
      when(() => mockRepository.watchWords(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value(testWordList));

      // Act
      useCase(userId: testUserId);

      // Assert
      verify(() => mockRepository.watchWords(userId: testUserId)).called(1);
    });

    test('should call repository.watchWords with null userId when not provided', () {
      // Arrange
      when(() => mockRepository.watchWords(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value(testWordList));

      // Act
      useCase();

      // Assert
      verify(() => mockRepository.watchWords(userId: null)).called(1);
    });

    test('should return a stream from repository', () {
      // Arrange
      when(() => mockRepository.watchWords(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value(testWordList));

      // Act
      final stream = useCase(userId: testUserId);

      // Assert
      expect(stream, isA<Stream<List<dynamic>>>());
    });

    test('should emit word list from repository stream', () {
      // Arrange
      when(() => mockRepository.watchWords(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value(testWordList));

      // Act
      final stream = useCase(userId: testUserId);

      // Assert
      expectLater(stream, emits(testWordList));
    });

    test('should emit empty list when no words', () {
      // Arrange
      when(() => mockRepository.watchWords(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value(testEmptyWordList));

      // Act
      final stream = useCase(userId: testUserId);

      // Assert
      expectLater(stream, emits(testEmptyWordList));
    });

    test('should emit multiple word lists over time', () {
      // Arrange
      when(() => mockRepository.watchWords(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.fromIterable([
            testEmptyWordList,
            [testWord],
            testWordList,
          ]));

      // Act
      final stream = useCase(userId: testUserId);

      // Assert
      expectLater(stream, emitsInOrder([
        testEmptyWordList,
        [testWord],
        testWordList,
      ]));
    });

    test('should propagate errors from repository stream', () {
      // Arrange
      final error = Exception('Stream error');
      when(() => mockRepository.watchWords(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.error(error));

      // Act
      final stream = useCase(userId: testUserId);

      // Assert
      expectLater(stream, emitsError(error));
    });
  });
}
