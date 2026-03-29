import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/script_analysis.dart';
import '../../../../core/utils/script_processor.dart';
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

  final List<ProcessedWord> _words = [];
  final Set<String> _pendingKnownWords = <String>{};
  ScriptSummary _summary = const ScriptSummary.empty();
  int _revision = 0;

  WorkspaceCubit(this._processScript, this._saveProcessedWords, this._toggleKnownWord) 
    : super(const WorkspaceState.initial());

  ScriptSummary get summary => _summary;
  List<ProcessedWord> get words => List.unmodifiable(_words);
  Set<String> get pendingKnownWords => Set.unmodifiable(_pendingKnownWords);
  bool get isProcessing => state.maybeMap(processing: (_) => true, orElse: () => false);

  Future<void> analyze(String text, {String? userId}) async {
    if (text.trim().isEmpty) return _reset();
    emit(const WorkspaceState.processing());
    final result = await _processScript(text, userId: userId);
    result.fold(
      (f) => emit(WorkspaceState.error(f.message)),
      (a) {
        _words..clear()..addAll(a.words);
        _summary = a.summary;
        _revision++;
        _pendingKnownWords.clear();
        _emitResults();
        unawaited(_saveProcessedWords(a.words, userId: userId));
      },
    );
  }

  void _reset() {
    _words.clear();
    _pendingKnownWords.clear();
    _summary = const ScriptSummary.empty();
    _revision++;
    emit(const WorkspaceState.initial());
  }

  void _emitResults() {
    final unknown = _words.where((w) => !w.isKnown).toList();
    final known = _words.where((w) => w.isKnown).toList();
    emit(WorkspaceState.results(words: List.from(_words), unknownWords: unknown, knownWords: known));
  }

  Future<void> toggleKnown(String wordText, {String? userId}) async {
    if (isProcessing || _pendingKnownWords.contains(wordText)) return;
    final currentRevision = _revision;
    _pendingKnownWords.add(wordText);
    _summary = _rebuildSummary(_words);
    _emitResults();
    
   
    unawaited(Future.delayed(Duration.zero, () => _persistToggle(wordText, currentRevision, userId)));
  }

  Future<void> _persistToggle(String text, int revision, String? userId) async {
    final result = await _toggleKnownWord(text, userId: userId);
    if (isClosed) return;

    result.fold(
      (f) {
        _pendingKnownWords.remove(text);
        emit(WorkspaceState.error(f.message));
        _emitResults();
      },
      (_) async {
       
        await Future.delayed(const Duration(milliseconds: 280));
        if (isClosed) return;
        _pendingKnownWords.remove(text);
        if (revision == _revision) _words.removeWhere((w) => w.wordText == text);
        _summary = _rebuildSummary(_words);
        _emitResults();
      },
    );
  }

  ScriptSummary _rebuildSummary(Iterable<ProcessedWord> ws) => ScriptSummary(
    totalWords: _summary.totalWords,
    uniqueWords: _summary.uniqueWords,
    newWords: ws.where((w) => !w.isKnown && !_pendingKnownWords.contains(w.wordText)).length,
  );
}
