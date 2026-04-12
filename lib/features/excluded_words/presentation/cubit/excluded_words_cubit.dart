import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:lexitrack/features/excluded_words/domain/usecases/add_excluded_word.dart';
import 'package:lexitrack/features/excluded_words/domain/usecases/delete_excluded_word.dart';
import 'package:lexitrack/features/excluded_words/domain/usecases/get_excluded_words.dart';
import 'package:lexitrack/features/excluded_words/domain/usecases/initialize_default_excluded_words.dart';
import 'package:lexitrack/features/excluded_words/domain/usecases/update_excluded_word.dart';
import 'package:lexitrack/features/excluded_words/presentation/cubit/excluded_words_state.dart';

class ExcludedWordsCubit extends Cubit<ExcludedWordsState> {
  final GetExcludedWordsUseCase _getExcludedWords;
  final AddExcludedWordUseCase _addExcludedWord;
  final UpdateExcludedWordUseCase _updateExcludedWord;
  final DeleteExcludedWordUseCase _deleteExcludedWord;
  final InitializeDefaultExcludedWordsUseCase _initializeDefaults;

  ExcludedWordsCubit({
    required GetExcludedWordsUseCase getExcludedWords,
    required AddExcludedWordUseCase addExcludedWord,
    required UpdateExcludedWordUseCase updateExcludedWord,
    required DeleteExcludedWordUseCase deleteExcludedWord,
    required InitializeDefaultExcludedWordsUseCase initializeDefaults,
  })  : _getExcludedWords = getExcludedWords,
        _addExcludedWord = addExcludedWord,
        _updateExcludedWord = updateExcludedWord,
        _deleteExcludedWord = deleteExcludedWord,
        _initializeDefaults = initializeDefaults,
        super(const ExcludedWordsState.initial());

  Future<void> loadExcludedWords() => _refreshExcludedWords(withLoading: true);

  Future<void> _refreshExcludedWords({bool withLoading = false}) async {
    if (withLoading) {
      emit(const ExcludedWordsState.loading());
    }

    final result = await _getExcludedWords(const NoParams()).run();
    result.fold(
      (failure) => emit(ExcludedWordsState.error(failure.toString())),
      (words) {
        if (words.isEmpty) {
          unawaited(initializeDefaults());
        } else {
          emit(ExcludedWordsState.loaded(words));
        }
      },
    );
  }

  Future<void> initializeDefaults() async {
    emit(const ExcludedWordsState.loading());
    final result = await _initializeDefaults(const NoParams()).run();
    result.fold(
      (failure) => emit(ExcludedWordsState.error(failure.toString())),
      (words) => emit(ExcludedWordsState.loaded(words)),
    );
  }

  Future<void> addWord(String word) async {
    final previous = state;
    final previousWords = previous.maybeWhen(
      loaded: (words) => words,
      orElse: () => null,
    );
    if (previousWords != null) {
      final optimistic = ExcludedWord(
        id: null,
        word: word,
        createdAt: DateTime.now(),
      );
      emit(ExcludedWordsState.loaded([...previousWords, optimistic]));
    }

    final result = await _addExcludedWord(word).run();
    result.fold(
      (failure) {
        if (previousWords != null) {
          emit(previous);
          return;
        }
        emit(ExcludedWordsState.error(failure.toString()));
      },
      (_) => unawaited(_refreshExcludedWords()),
    );
  }

  Future<void> updateWord(ExcludedWord word) async {
    final previous = state;
    final previousWords = previous.maybeWhen(
      loaded: (words) => words,
      orElse: () => null,
    );
    if (previousWords != null) {
      final updated = previousWords
          .map((item) => item.id == word.id ? word : item)
          .toList(growable: false);
      emit(ExcludedWordsState.loaded(updated));
    }

    final result = await _updateExcludedWord(word).run();
    result.fold(
      (failure) {
        if (previousWords != null) {
          emit(previous);
          return;
        }
        emit(ExcludedWordsState.error(failure.toString()));
      },
      (_) => unawaited(_refreshExcludedWords()),
    );
  }

  Future<void> deleteWord(int id) async {
    final previous = state;
    final previousWords = previous.maybeWhen(
      loaded: (words) => words,
      orElse: () => null,
    );
    if (previousWords != null) {
      final updated =
          previousWords.where((item) => item.id != id).toList(growable: false);
      emit(ExcludedWordsState.loaded(updated));
    }

    final result = await _deleteExcludedWord(id).run();
    result.fold(
      (failure) {
        if (previousWords != null) {
          emit(previous);
          return;
        }
        emit(ExcludedWordsState.error(failure.toString()));
      },
      (_) => unawaited(_refreshExcludedWords()),
    );
  }
}
