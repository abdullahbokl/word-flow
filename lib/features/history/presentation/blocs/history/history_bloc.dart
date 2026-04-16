import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
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
    on<LoadHistory>(_onLoadHistory, transformer: restartable());
    on<LoadMoreHistory>(_onLoadMore, transformer: restartable());
    on<HistoryUpdateReceived>(_onUpdateReceived);
    on<HistoryErrorReceived>(_onErrorReceived);
    on<DeleteHistoryItemEvent>(_onDeleteHistoryItem,
        transformer: restartable());
  }

  static const _pageSize = 20;
  final WatchHistory _watchHistory;
  final DeleteHistoryItem _deleteHistoryItem;

  StreamSubscription? _historySub;

  @override
  Future<void> close() async {
    await _historySub?.cancel();
    return super.close();
  }

  Future<void> _onLoadHistory(
      LoadHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: const BlocStatus.loading(), page: 0));

    await _restartHistorySubscription(limit: _pageSize);
  }

  Future<void> _onLoadMore(
      LoadMoreHistory event, Emitter<HistoryState> emit) async {
    if (state.hasReachedMax || !state.status.isSuccess) return;

    final nextPage = state.page + 1;
    emit(state.copyWith(page: nextPage));

    await _restartHistorySubscription(limit: (nextPage + 1) * _pageSize);
  }

  Future<void> _restartHistorySubscription({required int limit}) async {
    await _historySub?.cancel();
    _historySub = _watchHistory(HistoryPaginationParams(
      limit: limit,
      offset: 0,
    )).listen((res) {
      res.fold(
        (f) => add(HistoryEvent.errorReceived(message: f.message)),
        (items) => add(HistoryEvent.updateReceived(items: items)),
      );
    });
  }

  void _onUpdateReceived(
      HistoryUpdateReceived event, Emitter<HistoryState> emit) {
    emit(state.copyWith(
      status: BlocStatus.success(data: event.items),
      hasReachedMax: event.items.length < (state.page + 1) * _pageSize,
    ));
  }

  void _onErrorReceived(
      HistoryErrorReceived event, Emitter<HistoryState> emit) {
    emit(state.copyWith(status: BlocStatus.failure(error: event.message)));
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
      (_) => null, // Stream will update UI
    );
  }
}
