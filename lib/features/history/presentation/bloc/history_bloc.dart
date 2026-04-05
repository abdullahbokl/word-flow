import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/state/bloc_status.dart';
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
        super(const HistoryState(status: BlocStatus.initial())) {
    on<LoadHistory>(_onLoadHistory);
    on<HistoryUpdateReceived>(_onUpdateReceived);
    on<DeleteHistoryItemEvent>(_onDeleteHistoryItem);
  }

  final WatchHistory _watchHistory;
  final DeleteHistoryItem _deleteHistoryItem;

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: const BlocStatus.loading()));
    await emit.forEach(
      _watchHistory(),
      onData: (result) => result.fold(
        (f) => state.copyWith(status: BlocStatus.failure(error: f.message)),
        (items) => state.copyWith(status: BlocStatus.success(data: items)),
      ),
    );
  }

  void _onUpdateReceived(HistoryUpdateReceived event, Emitter<HistoryState> emit) {
    emit(state.copyWith(status: BlocStatus.success(data: event.items)));
  }

  Future<void> _onDeleteHistoryItem(
    DeleteHistoryItemEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await _deleteHistoryItem(
      event.id,
      deleteUniqueWords: event.deleteUniqueWords,
    );
    result.fold(
      (f) => emit(state.copyWith(status: BlocStatus.failure(error: f.message))),
      (_) => null, // List will update via stream
    );
  }
}
