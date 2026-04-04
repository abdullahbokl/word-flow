import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_history_item.dart';
import '../../domain/usecases/watch_history.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    required WatchHistory watchHistory,
    required DeleteHistoryItem deleteHistoryItem,
  })  : _watchHistory = watchHistory,
        _deleteHistoryItem = deleteHistoryItem,
        super(const HistoryInitial()) {
    on<LoadHistory>(_onLoad);
    on<HistoryUpdateReceived>(_onUpdateReceived);
    on<HistoryErrorReceived>(_onErrorReceived);
    on<DeleteHistoryItemEvent>(_onDelete);
  }

  final WatchHistory _watchHistory;
  final DeleteHistoryItem _deleteHistoryItem;
  StreamSubscription? _subscription;

  Future<void> _onLoad(LoadHistory e, Emitter<HistoryState> emit) async {
    emit(const HistoryLoading());
    await _subscription?.cancel();
    _subscription = _watchHistory().listen((result) {
      result.fold(
        (f) => add(HistoryErrorReceived(f.message)),
        (items) => add(HistoryUpdateReceived(items)),
      );
    });
  }

  void _onUpdateReceived(HistoryUpdateReceived e, Emitter<HistoryState> emit) {
    emit(HistoryLoaded(e.items));
  }

  void _onErrorReceived(HistoryErrorReceived e, Emitter<HistoryState> emit) {
    emit(HistoryFailure(e.message));
  }

  Future<void> _onDelete(
    DeleteHistoryItemEvent e,
    Emitter<HistoryState> emit,
  ) async {
    // Note: No need to call add(LoadHistory) because the stream will auto-update
    await _deleteHistoryItem(e.id, deleteUniqueWords: e.deleteUniqueWords).run();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
