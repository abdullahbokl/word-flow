import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wordflow/core/common/state/bloc_status.dart';
import 'package:wordflow/features/history/domain/usecases/delete_history_item.dart';
import 'package:wordflow/features/history/domain/usecases/watch_history.dart';
import 'package:wordflow/features/history/presentation/blocs/history/history_event.dart';
import 'package:wordflow/features/history/presentation/blocs/history/history_state.dart';

export 'history_event.dart';
export 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    required WatchHistory watchHistory,
    required DeleteHistoryItem deleteHistoryItem,
  })  : _watchHistory = watchHistory,
        _deleteHistoryItem = deleteHistoryItem,
        super(const HistoryState()) {
    on<LoadHistory>(_onLoadHistory);
    on<LoadMoreHistory>(_onLoadMore);
    on<HistoryUpdateReceived>(_onUpdateReceived);
    on<DeleteHistoryItemEvent>(_onDeleteHistoryItem);
  }

  static const _pageSize = 20;
  final WatchHistory _watchHistory;
  final DeleteHistoryItem _deleteHistoryItem;

  Future<void> _onLoadHistory(
      LoadHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: const BlocStatus.loading()));
    await _onFetch(emit: emit, force: true);
  }

  Future<void> _onLoadMore(
      LoadMoreHistory event, Emitter<HistoryState> emit) async {
    if (state.hasReachedMax || !state.status.isSuccess) return;
    await _onFetch(emit: emit);
  }

  Future<void> _onFetch({
    required Emitter<HistoryState> emit,
    bool force = false,
  }) async {
    final nextPage = force ? 0 : state.page + 1;
    final res = await _watchHistory(
      HistoryPaginationParams(
        limit: _pageSize,
        offset: nextPage * _pageSize,
      ),
    ).first;

    res.fold(
      (f) => emit(state.copyWith(status: BlocStatus.failure(error: f.message))),
      (items) {
        final currentItems = force ? [] : (state.status.data ?? []);
        emit(state.copyWith(
          status: BlocStatus.success(data: [...currentItems, ...items]),
          page: nextPage,
          hasReachedMax: items.length < _pageSize,
        ));
      },
    );
  }

  void _onUpdateReceived(
      HistoryUpdateReceived event, Emitter<HistoryState> emit) {
    emit(state.copyWith(status: BlocStatus.success(data: event.items)));
  }

  Future<void> _onDeleteHistoryItem(
    DeleteHistoryItemEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await _deleteHistoryItem(
      DeleteHistoryItemParams(
        id: event.id,
        deleteUniqueWords: event.deleteUniqueWords,
      ),
    );
    result.fold(
      (f) => emit(state.copyWith(status: BlocStatus.failure(error: f.message))),
      (_) =>
          add(const LoadHistory()), // Reload to maintain pagination integrity
    );
  }
}
