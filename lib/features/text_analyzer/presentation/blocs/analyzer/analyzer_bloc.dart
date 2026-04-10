import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lexitrack/core/common/models/word_with_local_freq.dart';
import 'package:lexitrack/core/common/state/bloc_status.dart';
import 'package:lexitrack/features/text_analyzer/domain/usecases/analyze_text.dart';
import 'package:lexitrack/features/text_analyzer/presentation/blocs/analyzer/analyzer_event.dart';
import 'package:lexitrack/features/text_analyzer/presentation/blocs/analyzer/analyzer_state.dart';

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

    final index = res.words.indexWhere((w) => w.word.id == e.wordId);
    if (index == -1) return;

    final currentWord = res.words[index];
    final isKnownNow = !currentWord.word.isKnown;
    final delta = currentWord.localFrequency;
    final updatedWords = List<WordWithLocalFreq>.from(res.words);
    updatedWords[index] = WordWithLocalFreq(
      word: currentWord.word.copyWith(isKnown: isKnownNow),
      localFrequency: currentWord.localFrequency,
    );

    final updatedResult = res.copyWith(
      words: updatedWords,
      knownWords: res.knownWords + (isKnownNow ? delta : -delta),
      unknownWords: res.unknownWords + (isKnownNow ? -delta : delta),
    );

    emit(state.copyWith(status: BlocStatus.success(data: updatedResult)));
  }

  void _onReset(ResetAnalysis e, Emitter<AnalyzerState> emit) {
    emit(const AnalyzerState());
  }
}
