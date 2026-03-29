import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/utils/uuid_generator.dart';
import 'package:word_flow/features/words/domain/entities/word.dart';
import 'package:word_flow/features/words/domain/usecases/delete_word.dart';
import 'package:word_flow/features/words/domain/usecases/update_word.dart';
import 'package:word_flow/features/words/domain/usecases/watch_words.dart';
import 'package:word_flow/features/words/presentation/cubit/library_state.dart';
import 'package:word_flow/features/words/presentation/cubit/library_optimistic_updates.dart';

@injectable
class LibraryCubit extends Cubit<LibraryState> with LibraryOptimisticUpdates {

  LibraryCubit(
    this._watchWords,
    this._updateWord,
    this._deleteWord,
  ) : super(const LibraryState.initial());
  final WatchWords _watchWords;
  final UpdateWord _updateWord;
  final DeleteWord _deleteWord;
  StreamSubscription? _wordsSubscription;
  Set<String> _pendingWordIds = <String>{};

  void init(String? userId) {
    emit(const LibraryState.loading());
    _wordsSubscription?.cancel();
    _wordsSubscription = _watchWords(userId: userId).listen((words) {
      state.maybeMap(
        loaded: (s) => emit(s.copyWith(words: words, pendingWordIds: _pendingWordIds)),
        orElse: () => emit(LibraryState.loaded(words: words, pendingWordIds: _pendingWordIds)),
      );
    });
  }

  void setFilter(WordsFilter filter) {
    state.maybeMap(
      loaded: (s) => emit(s.copyWith(filter: filter)),
      orElse: () {},
    );
  }

  void setSearch(String query) {
    state.maybeMap(
      loaded: (s) => emit(s.copyWith(searchQuery: query)),
      orElse: () {},
    );
  }

  Future<void> toggleKnown(WordEntity word) async {
    final updatedWord = word.copyWith(
      isKnown: !word.isKnown,
      lastUpdated: DateTime.now().toUtc(),
    );
    final prev = word;
    _markPending(word.id);
    _optimisticallyReplace(updatedWord);
    final result = await _updateWord(updatedWord);
    result.fold(
      (f) {
        _unmarkPending(word.id);
        _optimisticallyReplace(prev);
        emit(LibraryState.error(f.message));
        _reEmitLoaded();
      },
      (_) => _unmarkPending(word.id),
    );
  }

  Future<void> deleteWord(String id, {String? userId}) async {
    final loaded = state.maybeMap(loaded: (s) => s, orElse: () => null);
    WordEntity? prevWord;
    if (loaded != null) {
      for (final w in loaded.words) {
        if (w.id == id) {
          prevWord = w;
          break;
        }
      }
    }
    _markPending(id);
    if (prevWord != null) _optimisticallyRemove(id);
    final result = await _deleteWord(id, userId: userId);
    result.fold(
      (f) {
        _unmarkPending(id);
        if (prevWord != null) _optimisticallyUpsert(prevWord);
        emit(LibraryState.error(f.message));
        _reEmitLoaded();
      },
      (_) => _unmarkPending(id),
    );
  }

  Future<void> addWord(String text, bool isKnown, {String? userId}) async {
    final word = WordEntity(
      id: UuidGenerator.generate(),
      userId: userId,
      wordText: text,
      isKnown: isKnown,
      lastUpdated: DateTime.now().toUtc(),
    );
    _markPending(word.id);
    _optimisticallyUpsert(word);
    final result = await _updateWord(word);
    result.fold(
      (f) {
        _unmarkPending(word.id);
        _optimisticallyRemove(word.id);
        emit(LibraryState.error(f.message));
        _reEmitLoaded();
      },
      (_) => _unmarkPending(word.id),
    );
  }

  Future<void> updateWord(WordEntity word, String newText, bool newIsKnown) async {
    final prev = word;
    final updatedWord = word.copyWith(
      wordText: newText,
      isKnown: newIsKnown,
      lastUpdated: DateTime.now().toUtc(),
    );
    _markPending(word.id);
    _optimisticallyReplace(updatedWord);
    final result = await _updateWord(updatedWord);
    result.fold(
      (f) {
        _unmarkPending(word.id);
        _optimisticallyReplace(prev);
        emit(LibraryState.error(f.message));
        _reEmitLoaded();
      },
      (_) => _unmarkPending(word.id),
    );
  }

  void _markPending(String id) {
    _pendingWordIds = {..._pendingWordIds, id};
    _reEmitLoaded();
  }

  void _unmarkPending(String id) {
    if (!_pendingWordIds.contains(id)) return;
    _pendingWordIds = {..._pendingWordIds}..remove(id);
    _reEmitLoaded();
  }

  void _reEmitLoaded() {
    state.maybeMap(
      loaded: (s) => emit(s.copyWith(pendingWordIds: _pendingWordIds)),
      orElse: () {},
    );
  }

  void _optimisticallyReplace(WordEntity word) => 
    emit(applyOptimisticReplace(state, word, _pendingWordIds));

  void _optimisticallyUpsert(WordEntity word) => 
    emit(applyOptimisticUpsert(state, word, _pendingWordIds));

  void _optimisticallyRemove(String id) => 
    emit(applyOptimisticRemove(state, id, _pendingWordIds));

  @override
  Future<void> close() {
    _wordsSubscription?.cancel();
    return super.close();
  }
}

