import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/word_learning/domain/usecases/process_script.dart';
import 'package:word_flow/features/word_learning/domain/usecases/save_processed_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/toggle_known_word.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_state.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_cubit_helpers.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/get_text_analysis_config.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/utils/porter_stemmer.dart';
import 'package:injectable/injectable.dart';

@injectable
class WorkspaceCubit extends Cubit<WorkspaceState> with WorkspaceCubitHelpers {
  WorkspaceCubit(
    this._processScript,
    this._saveProcessedWords,
    this._getAnalysisConfig,
    this.toggleKnownWordUseCase,
    this.logger,
  ) : super(const WorkspaceState.initial());

  final ProcessScript _processScript;
  final SaveProcessedWords _saveProcessedWords;
  final GetTextAnalysisConfig _getAnalysisConfig;
  final AppLogger logger;

  @override
  final ToggleKnownWord toggleKnownWordUseCase;

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

  bool get isProcessing => state.maybeMap(
        processing: (_) => true,
        orElse: () => false,
      );

  Future<void> analyze(String text, {String? userId}) async {
    if (text.trim().isEmpty) return emit(const WorkspaceState.initial());
    
    final nextRevision = state.maybeMap(
      results: (s) => s.revision + 1,
      orElse: () => 1,
    );
    
    emit(const WorkspaceState.processing());
    
    final configResult = await _getAnalysisConfig();
    final config = configResult.getOrElse((_) => const TextAnalysisConfig(
      stopWords: {},
      language: 'english',
    ));
    
    final result = await _processScript(text, userId: userId, config: config);
    
    result.fold(
      (f) => emit(WorkspaceState.error(f.message, failure: f)),
      (a) {
        emit(WorkspaceState.results(
          words: a.words,
          summary: a.summary,
          config: config,
          pendingKnownWords: const <String>{},
          revision: nextRevision,
        ));
        
        _saveProcessedWords(a.words, userId: userId).then(
          (_) => logger.debug('Words saved successfully'),
          onError: (e, st) {
            logger.error('Failed to save processed words', e, st);
            if (!isClosed) {
              emit(WorkspaceState.error(
                'Failed to save words: please try again',
                failure: DatabaseFailure(e.toString()),
              ));
            }
          },
        );
      },
    );
  }

  Future<void> toggleKnown(String wordText, {String? userId}) async {
    state.maybeMap(
      results: (s) {
        if (s.pendingKnownWords.contains(wordText)) return;
        
        final targetText = s.config.useStemming ? PorterStemmer().stem(wordText) : wordText;
        
        final nextPending = <String>{...s.pendingKnownWords, wordText};
        emit(s.copyWith(
          pendingKnownWords: nextPending,
          summary: rebuildWorkspaceSummary(s.summary, s.words, nextPending),
        ));
        
        Future.value().then(
          (_) => persistToggle(
            targetText,
            revision: s.revision,
            fallbackSummary: s.summary,
            userId: userId,
          ),
        );
      },
      orElse: () {},
    );
  }

  void clearError() {
    state.maybeMap(
      results: (s) {
        if (s.lastError != null) emit(s.copyWith(lastError: null));
      },
      orElse: () {},
    );
  }
}
