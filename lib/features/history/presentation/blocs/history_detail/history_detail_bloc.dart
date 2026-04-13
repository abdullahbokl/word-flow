import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/common/state/bloc_status.dart';
import 'package:wordflow/features/history/domain/entities/history_detail.dart';
import 'package:wordflow/features/history/domain/usecases/watch_history_detail.dart';
import 'package:wordflow/features/history/presentation/blocs/history_detail/history_detail_event.dart';
import 'package:wordflow/features/history/presentation/blocs/history_detail/history_detail_state.dart';
import 'package:wordflow/features/lexicon/domain/usecases/toggle_word_status.dart';

class HistoryDetailBloc extends Bloc<HistoryDetailEvent, HistoryDetailState> {
  HistoryDetailBloc(this._watchDetail, this._toggleWord)
      : super(const HistoryDetailState()) {
    on<LoadHistoryDetail>(_onLoad);
    on<HistoryDetailUpdated>(_onUpdated);
    on<ToggleWordStatusInHistory>(_onToggle);
  }

  final WatchHistoryDetail _watchDetail;
  final ToggleWordStatus _toggleWord;
  StreamSubscription? _sub;

  void _onLoad(LoadHistoryDetail e, Emitter<HistoryDetailState> emit) {
    emit(state.copyWith(status: const BlocStatus.loading()));
    _sub?.cancel();
    _sub = _watchDetail(e.id).listen((res) => add(HistoryDetailUpdated(res)));
  }

  void _onUpdated(HistoryDetailUpdated e, Emitter<HistoryDetailState> emit) {
    e.result.fold(
      (f) => emit(state.copyWith(status: BlocStatus.failure(error: f.message))),
      (d) => emit(state.copyWith(status: BlocStatus<HistoryDetail>.success(data: d))),
    );
  }

  Future<void> _onToggle(
    ToggleWordStatusInHistory e,
    Emitter<HistoryDetailState> emit,
  ) async {
    // Current status is success, we just trigger the update.
    // Reactive stream will handle the UI update.
    await _toggleWord(e.wordId).run();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
