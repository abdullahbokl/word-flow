import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/common/state/bloc_status.dart';
import 'package:wordflow/features/lexicon/domain/usecases/toggle_word_status.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/analyze_text.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/update_analysis_counts.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/watch_analysis_result.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_event.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_state.dart';

class AnalyzerBloc extends Bloc<AnalyzerEvent, AnalyzerState> {
  AnalyzerBloc({
    required AnalyzeText analyzeText,
    required WatchAnalysisResult watchAnalysisResult,
    required UpdateAnalysisCounts updateAnalysisCounts,
    required ToggleWordStatus toggleWordStatus,
  })  : _analyzeText = analyzeText,
        _watchAnalysisResult = watchAnalysisResult,
        _updateAnalysisCounts = updateAnalysisCounts,
        _toggleWordStatus = toggleWordStatus,
        super(const AnalyzerState()) {
    on<StartAnalysis>(_onStart, transformer: restartable());
    on<ToggleWordStatusInResult>(_onToggleWordStatus,
        transformer: restartable());
    on<ResetAnalysis>(_onReset);
    on<SyncCurrentResultWithLexicon>(_onSync);
    on<AnalysisUpdateReceived>(_onUpdateReceived);
  }

  final AnalyzeText _analyzeText;
  final WatchAnalysisResult _watchAnalysisResult;
  final UpdateAnalysisCounts _updateAnalysisCounts;
  final ToggleWordStatus _toggleWordStatus;

  StreamSubscription? _analysisSub;

  @override
  Future<void> close() async {
    await _analysisSub?.cancel();
    return super.close();
  }

  Future<void> _onStart(StartAnalysis e, Emitter<AnalyzerState> emit) async {
    emit(state.copyWith(status: const BlocStatus.loading()));
    final result = await _analyzeText(
      AnalyzeTextParams(title: e.title.trim(), content: e.content),
    ).run();

    await result.fold(
      (f) async =>
          emit(state.copyWith(status: BlocStatus.failure(error: f.message))),
      (res) async {
        await _analysisSub?.cancel();
        _analysisSub = _watchAnalysisResult(res.id).listen((res) {
          res.fold(
            (f) => null, // Ignore stream errors for now
            (data) => add(AnalysisUpdateReceived(data)),
          );
        });
      },
    );
  }

  void _onUpdateReceived(
      AnalysisUpdateReceived e, Emitter<AnalyzerState> emit) {
    emit(state.copyWith(status: BlocStatus.success(data: e.result)));
  }

  Future<void> _onToggleWordStatus(
      ToggleWordStatusInResult e, Emitter<AnalyzerState> emit) async {
    if (!state.status.isSuccess) return;
    final res = state.status.data!;

    // Optimistic update removed to favor Drift SSOT stream
    // Persist to DB
    await _toggleWordStatus(e.wordId).run();
    await _updateAnalysisCounts(res.id).run();
  }

  void _onReset(ResetAnalysis e, Emitter<AnalyzerState> emit) {
    unawaited(_analysisSub?.cancel());
    _analysisSub = null;
    emit(const AnalyzerState());
  }

  Future<void> _onSync(
      SyncCurrentResultWithLexicon e, Emitter<AnalyzerState> emit) async {
    if (!state.status.isSuccess) return;
    final currentResult = state.status.data!;

    // If subscription is not active, restart it
    _analysisSub ??= _watchAnalysisResult(currentResult.id).listen((res) {
      res.fold(
        (f) => null,
        (data) => add(AnalysisUpdateReceived(data)),
      );
    });
  }
}
