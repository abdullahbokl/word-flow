import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/core/error/failures.dart';
import '../../lib/features/history/domain/entities/history_item.dart';
import '../../lib/features/history/domain/repositories/history_repository.dart';
import '../../lib/features/history/domain/usecases/delete_history_item.dart';
import '../../lib/features/history/domain/usecases/watch_history.dart';
import '../../lib/features/history/presentation/bloc/history_bloc.dart';
import '../../lib/features/history/presentation/bloc/history_event.dart';
import '../../lib/features/history/presentation/bloc/history_state.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

HistoryItem _makeItem({int id = 1}) {
  return HistoryItem(
    id: id,
    title: 'Test',
    contentSnippet: '...',
    createdAt: DateTime(2024),
    totalWords: 100,
    uniqueWords: 50,
    knownWords: 30,
    unknownWords: 20,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const AnalysisResult());
  });

  late MockHistoryRepository repository;
  late WatchHistory watchHistory;
  late DeleteHistoryItem deleteHistoryItem;
  late HistoryBloc bloc;

  setUp(() {
    repository = MockHistoryRepository();
    watchHistory = WatchHistory(repository);
    deleteHistoryItem = DeleteHistoryItem(repository);
    bloc = HistoryBloc(
      watchHistory: watchHistory,
      deleteHistoryItem: deleteHistoryItem,
    );
  });

  tearDown(() => bloc.close());

  group('HistoryBloc', () {
    test('starts with initial state', () {
      expect(bloc.state.status.isInitial, true);
      expect(bloc.state.items, isEmpty);
    });

    test('delete event triggers use case', () async {
      when(() => repository.deleteHistoryItem(any())).thenAnswer(
        (_) async => const Right(null),
      );

      bloc.add(DeleteHistoryItemEvent(1));
      // Allow async event to process
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => repository.deleteHistoryItem(1)).called(1);
    });
  });
}
