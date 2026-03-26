import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/script_processor.dart';
import '../../../../core/utils/script_analysis.dart';
import '../../domain/usecases/process_script.dart';
import '../../domain/usecases/save_processed_words.dart';
import '../../domain/usecases/toggle_known_word.dart';
import 'workspace_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class WorkspaceCubit extends Cubit<WorkspaceState> {
  final ProcessScript _processScript;
  final SaveProcessedWords _saveProcessedWords;
  final ToggleKnownWord _toggleKnownWord;
  ScriptSummary _summary = const ScriptSummary.empty();

  WorkspaceCubit(
    this._processScript,
    this._saveProcessedWords,
    this._toggleKnownWord,
  ) : super(const WorkspaceState.initial());

  ScriptSummary get summary => _summary;

  Future<void> analyze(String text, {String? userId}) async {
    if (text.trim().isEmpty) {
      _summary = const ScriptSummary.empty();
      emit(const WorkspaceState.initial());
      return;
    }
    emit(const WorkspaceState.processing());
    final result = await _processScript(text, userId: userId);
    result.fold(
      (failure) {
        _summary = const ScriptSummary.empty();
        emit(WorkspaceState.error(failure.message));
      },
      (analysis) {
        _summary = analysis.summary;
        emit(WorkspaceState.results(analysis.words));
      },
    );
  }

  Future<void> save(List<ProcessedWord> words, {String? userId}) async {
    final result = await _saveProcessedWords(words, userId: userId);
    result.fold(
      (failure) => emit(WorkspaceState.error(failure.message)),
      (_) {
        _summary = const ScriptSummary.empty();
        emit(const WorkspaceState.initial());
      },
    );
  }

  Future<void> toggleKnown(String wordText, {String? userId}) async {
    final result = await _toggleKnownWord(wordText, userId: userId);
    
    result.fold(
      (failure) => emit(WorkspaceState.error(failure.message)),
      (_) {
        // Optimistically remove from result list and update summary
        state.maybeMap(
          results: (res) {
            final updatedWords = res.words
                .where((w) => w.wordText != wordText)
                .toList();
            
            _summary = ScriptSummary(
              totalWords: _summary.totalWords,
              uniqueWords: _summary.uniqueWords,
              newWords: updatedWords.length,
            );
            
            emit(WorkspaceState.results(updatedWords));
          },
          orElse: () {},
        );
      },
    );
  }
}
