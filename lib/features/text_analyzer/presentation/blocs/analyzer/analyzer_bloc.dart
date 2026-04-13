import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/common/models/word_with_local_freq.dart';
import 'package:wordflow/core/common/state/bloc_status.dart';
import 'package:wordflow/features/lexicon/domain/usecases/toggle_word_status.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/analyze_text.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/get_analysis_result.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/update_analysis_counts.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_event.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_state.dart';

class AnalyzerBloc extends Bloc<AnalyzerEvent, AnalyzerState> {
  AnalyzerBloc({
    required AnalyzeText analyzeText,
    required GetAnalysisResult getAnalysisResult,
    required UpdateAnalysisCounts updateAnalysisCounts,
    required ToggleWordStatus toggleWordStatus,
  })  : _analyzeText = analyzeText,
        _getAnalysisResult = getAnalysisResult,
        _updateAnalysisCounts = updateAnalysisCounts,
        _toggleWordStatus = toggleWordStatus,
        super(const AnalyzerState()) {
    on<StartAnalysis>(_onStart);
    on<ToggleWordStatusInResult>(_onToggleWordStatus);
    on<ResetAnalysis>(_onReset);
    on<SyncCurrentResultWithLexicon>(_onSync);
  }

  final AnalyzeText _analyzeText;
  final GetAnalysisResult _getAnalysisResult;
  final UpdateAnalysisCounts _updateAnalysisCounts;
  final ToggleWordStatus _toggleWordStatus;

  Future<void> _onStart(StartAnalysis e, Emitter<AnalyzerState> emit) async {
    emit(state.copyWith(status: const BlocStatus.loading()));
    final result = await _analyzeText(
      AnalyzeTextParams(title: e.title.trim(), content: e.content),
    ).run();
    result.fold(
      (f) => emit(state.copyWith(status: BlocStatus.failure(error: f.message))),
      (res) => emit(state.copyWith(status: BlocStatus.success(data: res))),
    );
  }

  Future<void> _onToggleWordStatus(
      ToggleWordStatusInResult e, Emitter<AnalyzerState> emit) async {
    if (!state.status.isSuccess) return;
    final res = state.status.data!;

    final index = res.words.indexWhere((w) => w.word.id == e.wordId);
    if (index == -1) return;

    final currentWord = res.words[index];
    final isKnownNow = !currentWord.word.isKnown;
    final updatedWords = List<WordWithLocalFreq>.from(res.words);
    updatedWords[index] = WordWithLocalFreq(
      word: currentWord.word.copyWith(isKnown: isKnownNow),
      localFrequency: currentWord.localFrequency,
    );

    final updatedResult = res.copyWith(
      words: updatedWords,
      knownWords: res.knownWords + (isKnownNow ? 1 : -1),
      unknownWords: res.unknownWords + (isKnownNow ? -1 : 1),
    );

    emit(state.copyWith(status: BlocStatus.success(data: updatedResult)));

    // Persist to DB
    await _toggleWordStatus(e.wordId).run();
    await _updateAnalysisCounts(res.id).run();
  }

  void _onReset(ResetAnalysis e, Emitter<AnalyzerState> emit) {
    emit(const AnalyzerState());
  }

  Future<void> _onSync(
      SyncCurrentResultWithLexicon e, Emitter<AnalyzerState> emit) async {
    if (!state.status.isSuccess) return;
    final currentResult = state.status.data!;

    final result = await _getAnalysisResult(currentResult.id).run();
    result.fold(
      (f) => null, // Silently fail sync
      (updatedResult) =>
          emit(state.copyWith(status: BlocStatus.success(data: updatedResult))),
    );
  }
}
