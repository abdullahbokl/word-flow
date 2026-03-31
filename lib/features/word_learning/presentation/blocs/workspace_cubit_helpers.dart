import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_state.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/toggle_known_word.dart';

mixin WorkspaceCubitHelpers on Cubit<WorkspaceState> {
  ToggleKnownWord get toggleKnownWordUseCase;

  Future<void> persistToggle(
    String text, {
    required int revision,
    required ScriptSummary fallbackSummary,
    String? userId,
  }) async {
    final result = await toggleKnownWordUseCase(text, userId: userId);
    if (isClosed) return;

    await result.fold<Future<void>>(
      (f) async {
        final snapshot = state.maybeMap(results: (s) => s, orElse: () => null);
        if (snapshot == null || snapshot.revision != revision) return;

        final nextPending = <String>{...snapshot.pendingKnownWords}
          ..remove(text);
        emit(
          snapshot.copyWith(
            pendingKnownWords: nextPending,
            summary: rebuildWorkspaceSummary(
              fallbackSummary,
              snapshot.words,
              nextPending,
            ),
            lastError: f.message,
          ),
        );
      },
      (_) async {
        await Future.delayed(const Duration(milliseconds: 280));
        if (isClosed) return;

        final snapshot = state.maybeMap(results: (s) => s, orElse: () => null);
        if (snapshot == null || snapshot.revision != revision) return;

        final nextPending = <String>{...snapshot.pendingKnownWords}
          ..remove(text);
        final nextWords = snapshot.words
            .where((w) => w.wordText != text)
            .toList(growable: false);
        emit(
          snapshot.copyWith(
            words: nextWords,
            pendingKnownWords: nextPending,
            summary: rebuildWorkspaceSummary(
              fallbackSummary,
              nextWords,
              nextPending,
            ),
            lastError: null,
          ),
        );
      },
    );
  }

  ScriptSummary rebuildWorkspaceSummary(
    ScriptSummary base,
    Iterable<ProcessedWord> ws,
    Set<String> pending,
  ) => ScriptSummary(
    totalWords: base.totalWords,
    uniqueWords: base.uniqueWords,
    newWords: ws
        .where((w) => !w.isKnown && !pending.contains(w.wordText))
        .length,
  );
}
