import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/add_excluded_word.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/delete_excluded_word.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/get_excluded_words.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/initialize_default_excluded_words.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/update_excluded_word.dart';
import 'package:wordflow/features/excluded_words/presentation/cubit/excluded_words_state.dart';

class ExcludedWordsCubit extends Cubit<ExcludedWordsState> {
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

  final GetExcludedWordsUseCase _getExcludedWords;
  final AddExcludedWordUseCase _addExcludedWord;
  final UpdateExcludedWordUseCase _updateExcludedWord;
  final DeleteExcludedWordUseCase _deleteExcludedWord;
  final InitializeDefaultExcludedWordsUseCase _initializeDefaults;

  StreamSubscription? _subscription;

  Future<void> loadExcludedWords() async {
    emit(const ExcludedWordsState.loading());
    await _subscription?.cancel();
    _subscription = _getExcludedWords.watch().listen((result) {
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
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
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
    final result = await _addExcludedWord(word).run();
    result.fold(
      (failure) => emit(ExcludedWordsState.error(failure.toString())),
      (_) => null, // Stream will update UI
    );
  }

  Future<void> updateWord(ExcludedWord word) async {
    final result = await _updateExcludedWord(word).run();
    result.fold(
      (failure) => emit(ExcludedWordsState.error(failure.toString())),
      (_) => null, // Stream will update UI
    );
  }

  Future<void> deleteWord(int id) async {
    final result = await _deleteExcludedWord(id).run();
    result.fold(
      (failure) => emit(ExcludedWordsState.error(failure.toString())),
      (_) => null, // Stream will update UI
    );
  }
}
