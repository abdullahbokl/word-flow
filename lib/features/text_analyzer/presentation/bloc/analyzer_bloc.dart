import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../history/domain/entities/history_detail.dart';
import '../../domain/usecases/analyze_text.dart';
import 'analyzer_event.dart';
import 'analyzer_state.dart';

class AnalyzerBloc extends Bloc<AnalyzerEvent, AnalyzerState> {
  AnalyzerBloc({required AnalyzeText analyzeText})
      : _analyzeText = analyzeText,
        super(const AnalyzerInitial()) {
    on<StartAnalysis>(_onStart);
    on<ToggleWordStatusInResult>(_onToggleWordStatus);
    on<ResetAnalysis>(_onReset);
  }

  final AnalyzeText _analyzeText;

  Future<void> _onStart(StartAnalysis e, Emitter<AnalyzerState> emit) async {
    emit(const AnalyzerLoading());
    final result = await _analyzeText(title: e.title.trim(), content: e.content).run();
    result.fold(
      (f) => emit(AnalyzerFailure(f.message)),
      (res) => emit(AnalyzerSuccess(res)),
    );
  }

  void _onToggleWordStatus(ToggleWordStatusInResult e, Emitter<AnalyzerState> emit) {
    if (state is! AnalyzerSuccess) return;
    final res = (state as AnalyzerSuccess).result;

    final updatedWords = res.words.map((w) {
      if (w.word.id == e.wordId) {
        return WordWithLocalFreq(
          word: w.word.copyWith(isKnown: !w.word.isKnown),
          localFrequency: w.localFrequency,
        );
      }
      return w;
    }).toList();

    // Re-calculate stats
    int newKnownWords = 0;
    int newUnknownUnique = 0;
    for (final w in updatedWords) {
      if (w.word.isKnown) {
        newKnownWords += w.localFrequency;
      } else {
        newUnknownUnique++;
      }
    }

    final updatedResult = res.copyWith(
      words: updatedWords,
      knownWords: newKnownWords,
      unknownWords: newUnknownUnique,
    );

    emit(AnalyzerSuccess(updatedResult));
  }

  void _onReset(ResetAnalysis e, Emitter<AnalyzerState> emit) {
    emit(const AnalyzerInitial());
  }
}
