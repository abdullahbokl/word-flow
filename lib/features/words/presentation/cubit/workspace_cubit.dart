import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/words/domain/entities/script_analysis.dart';
import 'package:word_flow/features/words/domain/entities/processed_word.dart';
import 'package:word_flow/features/words/domain/usecases/process_script.dart';
import 'package:word_flow/features/words/domain/usecases/save_processed_words.dart';
import 'package:word_flow/features/words/domain/usecases/toggle_known_word.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class WorkspaceCubit extends Cubit<WorkspaceState> {

  WorkspaceCubit(this._processScript, this._saveProcessedWords, this._toggleKnownWord) 
    : super(const WorkspaceState.initial());
  final ProcessScript _processScript;
  final SaveProcessedWords _saveProcessedWords;
  final ToggleKnownWord _toggleKnownWord;

  ScriptSummary get summary => state.maybeMap(
        results: (s) => s.summary,
        orElse: () => const ScriptSummary.empty(),
      );
  List<ProcessedWord> get words => state.maybeMap(
        results: (s) => s.words,
        orElse: () => const <ProcessedWord>[],
      );
  Set<String> get pendingKnownWords => state.maybeMap(
        results: (s) => s.pendingKnownWords,
        orElse: () => const <String>{},
      );
  bool get isProcessing => state.maybeMap(processing: (_) => true, orElse: () => false);

  Future<void> analyze(String text, {String? userId}) async {
    if (text.trim().isEmpty) return _reset();
    final nextRevision = state.maybeMap(
      results: (s) => s.revision + 1,
      orElse: () => 1,
    );
    emit(const WorkspaceState.processing());
    final result = await _processScript(text, userId: userId);
    result.fold(
      (f) => emit(WorkspaceState.error(f.message)),
      (a) {
        emit(
          WorkspaceState.results(
            words: a.words,
            summary: a.summary,
            pendingKnownWords: const <String>{},
            revision: nextRevision,
            lastError: null,
          ),
        );
        unawaited(_saveProcessedWords(a.words, userId: userId));
      },
    );
  }

  void _reset() {
    emit(const WorkspaceState.initial());
  }

  Future<void> toggleKnown(String wordText, {String? userId}) async {
    state.maybeMap(
      results: (s) {
        if (s.pendingKnownWords.contains(wordText)) return;

        final nextPending = <String>{...s.pendingKnownWords, wordText};
        emit(
          s.copyWith(
            pendingKnownWords: nextPending,
            summary: _rebuildSummary(s.summary, s.words, nextPending),
          ),
        );

        unawaited(() async {
          await Future<void>.delayed(Duration.zero);
          await _persistToggle(
            wordText,
            revision: s.revision,
            fallbackSummary: s.summary,
            userId: userId,
          );
        }());
      },
      orElse: () {},
    );
  }

  Future<void> _persistToggle(
    String text, {
    required int revision,
    required ScriptSummary fallbackSummary,
    String? userId,
  }) async {
    final result = await _toggleKnownWord(text, userId: userId);
    if (isClosed) return;

    await result.fold<Future<void>>(
      (f) async {
        final snapshot = state.maybeMap(results: (s) => s, orElse: () => null);
        if (snapshot == null || snapshot.revision != revision) return;

        final nextPending = <String>{...snapshot.pendingKnownWords}..remove(text);
        emit(snapshot.copyWith(
          pendingKnownWords: nextPending,
          summary: _rebuildSummary(fallbackSummary, snapshot.words, nextPending),
          lastError: f.message,
        ));
      },
      (_) async {
        await Future.delayed(const Duration(milliseconds: 280));
        if (isClosed) return;

        final snapshot = state.maybeMap(results: (s) => s, orElse: () => null);
        if (snapshot == null || snapshot.revision != revision) return;

        final nextPending = <String>{...snapshot.pendingKnownWords}..remove(text);
        final nextWords = snapshot.words
            .where((w) => w.wordText != text)
            .toList(growable: false);
        emit(
          snapshot.copyWith(
            words: nextWords,
            pendingKnownWords: nextPending,
            summary: _rebuildSummary(fallbackSummary, nextWords, nextPending),
            lastError: null,
          ),
        );
      },
    );
  }

  void clearError() {
    state.maybeMap(
      results: (s) {
        if (s.lastError != null) {
          emit(s.copyWith(lastError: null));
        }
      },
      orElse: () {},
    );
  }

  ScriptSummary _rebuildSummary(
    ScriptSummary base,
    Iterable<ProcessedWord> ws,
    Set<String> pending,
  ) =>
      ScriptSummary(
        totalWords: base.totalWords,
        uniqueWords: base.uniqueWords,
        newWords: ws
            .where((w) => !w.isKnown && !pending.contains(w.wordText))
            .length,
      );
}
