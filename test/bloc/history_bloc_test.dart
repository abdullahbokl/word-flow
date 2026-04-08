import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/features/history/domain/entities/history_item.dart';
import 'package:lexitrack/features/history/domain/repositories/history_repository.dart';
import 'package:lexitrack/features/history/domain/usecases/delete_history_item.dart';
import 'package:lexitrack/features/history/domain/usecases/watch_history.dart';
import 'package:lexitrack/features/history/presentation/blocs/history/history_bloc.dart';
import 'package:lexitrack/features/history/presentation/blocs/history/history_event.dart';
import 'package:lexitrack/features/history/presentation/blocs/history/history_state.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

void main() {
  group('HistoryBloc', () {
    late MockHistoryRepository repository;
    late HistoryBloc bloc;
    late WatchHistory watchHistory;
    late DeleteHistoryItem deleteHistoryItem;

    final testItems = [
      HistoryItem(
        id: 1,
        title: 'Test Analysis',
        totalWords: 100,
        uniqueWords: 50,
        createdAt: DateTime(2024, 1, 1),
        contentSnippet: 'Test content...',
      ),
    ];

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

    test('starts with initial state', () {
      expect(bloc.state.status.isInitial, true);
    });

    blocTest<HistoryBloc, HistoryState>(
      'emits [loading, success] when LoadHistory succeeds',
      build: () {
        when(() => repository.watchHistory()).thenAnswer(
          (_) => Stream.value(Right<Failure, List<HistoryItem>>(testItems)),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHistory()),
      expect: () => [
        isA<HistoryState>().having((s) => s.status.isLoading, 'isLoading', true),
        isA<HistoryState>().having(
          (s) => s.status.isSuccess,
          'isSuccess',
          true,
        ),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'emits [loading, failure] when LoadHistory fails',
      build: () {
        when(() => repository.watchHistory()).thenAnswer(
          (_) => Stream.value(Left<Failure, List<HistoryItem>>(
            DatabaseFailure('Database error'),
          )),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHistory()),
      expect: () => [
        isA<HistoryState>().having((s) => s.status.isLoading, 'isLoading', true),
        isA<HistoryState>().having((s) => s.status.isFailed, 'isFailed', true),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'calls deleteHistoryItem when DeleteHistoryItemEvent is added',
      build: () {
        when(() => repository.deleteHistoryItem(1, deleteUniqueWords: false))
            .thenAnswer((_) async => const Right<Failure, void>(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteHistoryItemEvent(1)),
      verify: (_) {
        verify(() => repository.deleteHistoryItem(1, deleteUniqueWords: false))
            .called(1);
      },
    );
  });
}
