import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/features/words/domain/usecases/watch_pending_count.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockSyncRepository mockRepository;
  late WatchPendingCount useCase;

  setUp(() {
    mockRepository = MockSyncRepository();
    useCase = WatchPendingCount(mockRepository);
  });

  group('WatchPendingCount', () {
    test('should return a stream from repository', () {
      // Arrange
      when(() => mockRepository.watchPendingCount())
          .thenAnswer((_) => Stream.value(5));

      // Act
      final stream = useCase();

      // Assert
      expect(stream, isA<Stream<int>>());
    });

    test('should emit pending counts from repository stream', () {
      // Arrange
      when(() => mockRepository.watchPendingCount())
          .thenAnswer((_) => Stream.fromIterable([1, 2, 3]));

      // Act
      final stream = useCase();

      // Assert
      expectLater(stream, emitsInOrder([1, 2, 3]));
    });

    test('should emit single value from repository', () {
      // Arrange
      const testCount = 7;
      when(() => mockRepository.watchPendingCount())
          .thenAnswer((_) => Stream.value(testCount));

      // Act
      final stream = useCase();

      // Assert
      expectLater(stream, emits(testCount));
    });

    test('should emit zero when no pending words', () {
      // Arrange
      when(() => mockRepository.watchPendingCount())
          .thenAnswer((_) => Stream.value(0));

      // Act
      final stream = useCase();

      // Assert
      expectLater(stream, emits(0));
    });

    test('should propagate errors from repository stream', () {
      // Arrange
      final error = Exception('Stream error');
      when(() => mockRepository.watchPendingCount())
          .thenAnswer((_) => Stream.error(error));

      // Act
      final stream = useCase();

      // Assert
      expectLater(stream, emitsError(error));
    });

    test('should call repository.watchPendingCount', () {
      // Arrange
      when(() => mockRepository.watchPendingCount())
          .thenAnswer((_) => Stream.value(5));

      // Act
      useCase();

      // Assert
      verify(() => mockRepository.watchPendingCount()).called(1);
    });
  });
}
