import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/watch_history_detail.dart';
import 'history_detail_event.dart';
import 'history_detail_state.dart';

class HistoryDetailBloc extends Bloc<HistoryDetailEvent, HistoryDetailState> {
  HistoryDetailBloc(this._watchHistoryDetail) : super(HistoryDetailInitial()) {
    on<LoadHistoryDetail>(_onLoad);
    on<HistoryDetailUpdated>(_onUpdated);
  }

  final WatchHistoryDetail _watchHistoryDetail;
  StreamSubscription? _subscription;

  Future<void> _onLoad(
    LoadHistoryDetail event,
    Emitter<HistoryDetailState> emit,
  ) async {
    emit(HistoryDetailLoading());
    await _subscription?.cancel();
    _subscription = _watchHistoryDetail(event.id).listen(
      (result) => add(HistoryDetailUpdated(result)),
    );
  }

  void _onUpdated(
    HistoryDetailUpdated event,
    Emitter<HistoryDetailState> emit,
  ) {
    event.result.fold(
      (failure) => emit(HistoryDetailFailure(failure.message)),
      (detail) => emit(HistoryDetailLoaded(detail)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
