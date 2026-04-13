import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/history/data/datasources/history_local_ds.dart';
import 'package:wordflow/features/history/data/repositories/history_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockHistoryLocalDataSource extends Mock implements HistoryLocalDataSource {}

void main() {
  late HistoryRepositoryImpl repository;
  late MockHistoryLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockHistoryLocalDataSource();
    repository = HistoryRepositoryImpl(mockDataSource);
  });

  final tTextRow = AnalyzedTextRow(
    id: 1,
    title: 'Test',
    content: 'Content',
    totalWords: 10,
    uniqueWords: 5,
    createdAt: DateTime(2024),
    knownWords: 3,
    unknownWords: 2,
  );

  group('getHistory', () {
    test('should return history list', () async {
      when(() => mockDataSource.getHistory()).thenAnswer((_) async => [tTextRow]);

      final result = await repository.getHistory();

      expect(result.isRight(), true);
      result.fold(( l) {}, (items) => expect(items.first.title, 'Test'));
    });
  });

  group('deleteHistoryItem', () {
    test('should call data source to delete', () async {
      when(() => mockDataSource.deleteHistoryItem(any())).thenAnswer((_) async => unit);

      final result = await repository.deleteHistoryItem(1);

      expect(result.isRight(), true);
      verify(() => mockDataSource.deleteHistoryItem(1)).called(1);
    });
  });
}
