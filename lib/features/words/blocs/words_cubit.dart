import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/features/words/models/word.dart';
import 'package:word_flow/features/words/models/analysis.dart';
import 'package:word_flow/features/words/repositories/word_repository.dart';
import 'package:word_flow/features/words/domain/usecases/analyze_script_usecase.dart';
import 'package:word_flow/features/words/domain/usecases/toggle_word_status_usecase.dart';
import 'package:word_flow/core/errors/failures.dart';

part 'words_cubit.freezed.dart';

@freezed
class WordsState with _$WordsState {
  const factory WordsState.initial() = _Initial;
  const factory WordsState.loading() = _Loading;
  const factory WordsState.analyzing({required double progress}) = _Analyzing;
  const factory WordsState.results({
    required List<AnalyzedWord> analyzedWords,
    required ScriptSummary summary,
    required TextAnalysisConfig config,
  }) = _Results;
  const factory WordsState.library({
    required List<Word> words,
    required int totalCount,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _Library;
  const factory WordsState.error(String message, {Failure? failure}) = _Error;
}

@injectable
class WordsCubit extends Cubit<WordsState> {
  WordsCubit(
    this._repository,
    this._analyzeScriptUseCase,
    this._toggleWordStatusUseCase,
  ) : super(const WordsState.initial());

  final WordRepository _repository;
  final AnalyzeScriptUseCase _analyzeScriptUseCase;
  final ToggleWordStatusUseCase _toggleWordStatusUseCase;

  static const int _pageSize = 50;

  Future<void> analyze(String text, TextAnalysisConfig config) async {
    if (text.trim().isEmpty) {
      emit(const WordsState.initial());
      return;
    }

    emit(const WordsState.analyzing(progress: 0.1));

    final result = await _analyzeScriptUseCase(
      AnalyzeScriptParams(text: text, config: config),
    );

    result.fold(
      (f) {
        emit(WordsState.error(f.message, failure: f));
      },
      (analysis) => emit(
        WordsState.results(
          analyzedWords: analysis.words,
          summary: analysis.summary,
          config: config,
        ),
      ),
    );
  }

  Future<void> loadLibrary({bool refresh = false}) async {
    if (!refresh && state is _Library && !(state as _Library).hasMore) return;

    final currentOffset = refresh
        ? 0
        : (state is _Library ? (state as _Library).words.length : 0);

    if (refresh) {
      emit(const WordsState.loading());
    } else if (state is _Library) {
      emit((state as _Library).copyWith(isLoadingMore: true));
    }

    final result = await _repository.getWords(
      limit: _pageSize,
      offset: currentOffset,
    );

    final countResult = await _repository.countWords();
    final totalCount = countResult.getOrElse((_) => 0);

    result.fold(
      (f) {
        emit(WordsState.error(f.message, failure: f));
      },
      (newWords) {
        final previousWords = refresh
            ? <Word>[]
            : (state is _Library ? (state as _Library).words : <Word>[]);
        final allWords = [...previousWords, ...newWords];

        emit(
          WordsState.library(
            words: allWords,
            totalCount: totalCount,
            hasMore: allWords.length < totalCount,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> toggleKnown(String wordText) async {
    final result = await _toggleWordStatusUseCase(wordText);

    result.fold((f) => emit(WordsState.error(f.message, failure: f)), (_) {
      // Refresh current view
      state.maybeMap(
        results: (s) {
          final updatedWords = s.analyzedWords.map((w) {
            if (w.wordText == wordText) {
              return AnalyzedWord(
                wordText: w.wordText,
                totalCount: w.totalCount,
                isKnown: !w.isKnown,
              );
            }
            return w;
          }).toList();

          emit(s.copyWith(analyzedWords: updatedWords));
        },
        library: (s) => loadLibrary(refresh: true),
        orElse: () {},
      );
    });
  }

  Future<void> deleteWord(String id) async {
    final result = await _repository.deleteWord(id);
    result.fold((f) => emit(WordsState.error(f.message, failure: f)), (_) {
      if (state is _Library) {
        loadLibrary(refresh: true);
      }
    });
  }
}
