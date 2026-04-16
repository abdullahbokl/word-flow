import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/history/domain/entities/history_item.dart';
import 'package:wordflow/features/history/domain/usecases/delete_history_item.dart';
import 'package:wordflow/features/history/domain/usecases/watch_history.dart';
import 'package:wordflow/features/history/presentation/blocs/history/history_bloc.dart';

class MockWatchHistory extends Mock implements WatchHistory {}

class MockDeleteHistoryItem extends Mock implements DeleteHistoryItem {}

void main() {
  late HistoryBloc bloc;
  late MockWatchHistory mockWatchHistory;
  late MockDeleteHistoryItem mockDeleteHistoryItem;
  late StreamController<Either<Failure, List<HistoryItem>>> historyController;

  setUpAll(() {
    registerFallbackValue(const HistoryPaginationParams());
  });

  setUp(() {
    mockWatchHistory = MockWatchHistory();
    mockDeleteHistoryItem = MockDeleteHistoryItem();
    historyController =
        StreamController<Either<Failure, List<HistoryItem>>>.broadcast();

    when(() => mockWatchHistory(any()))
        .thenAnswer((_) => historyController.stream);

    bloc = HistoryBloc(
      watchHistory: mockWatchHistory,
      deleteHistoryItem: mockDeleteHistoryItem,
    );
  });

  tearDown(() {
    historyController.close();
    bloc.close();
  });

  group('HistoryBloc SSOT', () {
    final tItems = [
      HistoryItem(
        id: 1,
        title: 'Test 1',
        totalWords: 10,
        uniqueWords: 5,
        createdAt: DateTime.now(),
        contentSnippet: 'Snippet',
      ),
    ];

    blocTest<HistoryBloc, HistoryState>(
      'emits success state when stream emits new items after LoadHistory',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(const HistoryEvent.load());
        await Future.delayed(Duration.zero);
        historyController.add(Right(tItems));
      },
      expect: () => [
        isA<HistoryState>()
            .having((s) => s.status.isLoading, 'isLoading', true),
        isA<HistoryState>()
            .having((s) => s.status.isSuccess, 'isSuccess', true)
            .having((s) => s.status.data, 'data', tItems),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'auto-updates state when stream emits new items without new events',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(const HistoryEvent.load());
        await Future.delayed(Duration.zero);
        historyController.add(const Right([]));
        await Future.delayed(Duration.zero);
        historyController.add(Right(tItems));
      },
      skip: 2,
      expect: () => [
        isA<HistoryState>().having((s) => s.status.data, 'data', tItems),
      ],
    );
  });

  group('HistoryBloc Concurrency', () {
    blocTest<HistoryBloc, HistoryState>(
      'LoadHistory cancels previous subscription (restartable)',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(const HistoryEvent.load());
        await Future.delayed(Duration.zero);
        bloc.add(const HistoryEvent.load());
      },
      verify: (_) {
        verify(() => mockWatchHistory(any())).called(2);
      },
    );
  });
}
