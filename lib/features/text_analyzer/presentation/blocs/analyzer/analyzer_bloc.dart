import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/common/models/word_with_local_freq.dart';
import '../../../../../core/common/state/bloc_status.dart';
import '../../../domain/usecases/analyze_text.dart';
import 'analyzer_event.dart';
import 'analyzer_state.dart';

class AnalyzerBloc extends Bloc<AnalyzerEvent, AnalyzerState> {
  AnalyzerBloc({required AnalyzeText analyzeText})
      : _analyzeText = analyzeText,
        super(const AnalyzerState()) {
    on<StartAnalysis>(_onStart);
    on<ToggleWordStatusInResult>(_onToggleWordStatus);
    on<ResetAnalysis>(_onReset);
  }

  final AnalyzeText _analyzeText;

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

  void _onToggleWordStatus(
      ToggleWordStatusInResult e, Emitter<AnalyzerState> emit) {
    if (!state.status.isSuccess) return;
    final res = state.status.data!;

    final updatedWords = res.words.map((w) {
      if (w.word.id == e.wordId) {
        return WordWithLocalFreq(
          word: w.word.copyWith(isKnown: !w.word.isKnown),
          localFrequency: w.localFrequency,
        );
      }
      return w;
    }).toList();

    int newKnownWords = 0;
    int newUnknownTokens = 0;
    for (final w in updatedWords) {
      if (w.word.isKnown) {
        newKnownWords += w.localFrequency;
      } else {
        newUnknownTokens += w.localFrequency;
      }
    }

    final updatedResult = res.copyWith(
      words: updatedWords,
      knownWords: newKnownWords,
      unknownWords: newUnknownTokens,
    );

    emit(state.copyWith(status: BlocStatus.success(data: updatedResult)));
  }

  void _onReset(ResetAnalysis e, Emitter<AnalyzerState> emit) {
    emit(const AnalyzerState());
  }
}
