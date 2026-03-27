import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/word.dart';
import '../../domain/usecases/delete_word.dart';
import '../../domain/usecases/update_word.dart';
import '../../domain/usecases/watch_words.dart';
import 'library_state.dart';

@injectable
class LibraryCubit extends Cubit<LibraryState> {
  final WatchWords _watchWords;
  final UpdateWord _updateWord;
  final DeleteWord _deleteWord;
  StreamSubscription? _wordsSubscription;
  Set<String> _pendingWordIds = <String>{};

  LibraryCubit(
    this._watchWords,
    this._updateWord,
    this._deleteWord,
  ) : super(const LibraryState.initial());

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

  Future<void> toggleKnown(Word word) async {
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
    Word? prevWord;
    if (loaded != null) {
      for (final w in loaded.words) {
        if (w.id == id) {
          prevWord = w;
          break;
        }
      }
    }
    _markPending(id);
    if (prevWord != null) {
      _optimisticallyRemove(id);
    }
    final result = await _deleteWord(id, userId: userId);
    result.fold(
      (f) {
        _unmarkPending(id);
        if (prevWord != null) {
          _optimisticallyUpsert(prevWord);
        }
        emit(LibraryState.error(f.message));
        _reEmitLoaded();
      },
      (_) => _unmarkPending(id),
    );
  }

  Future<void> addWord(String text, bool isKnown, {String? userId}) async {
    final word = Word(
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

  Future<void> updateWord(Word word, String newText, bool newIsKnown) async {
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

  void _optimisticallyReplace(Word word) {
    state.maybeMap(
      loaded: (s) {
        final updated = s.words
            .map((w) => w.id == word.id ? word : w)
            .toList(growable: false);
        emit(s.copyWith(words: updated, pendingWordIds: _pendingWordIds));
      },
      orElse: () {},
    );
  }

  void _optimisticallyUpsert(Word word) {
    state.maybeMap(
      loaded: (s) {
        final exists = s.words.any((w) => w.id == word.id);
        final next = exists
            ? s.words.map((w) => w.id == word.id ? word : w).toList(growable: false)
            : <Word>[word, ...s.words];
        emit(s.copyWith(words: next, pendingWordIds: _pendingWordIds));
      },
      orElse: () {},
    );
  }

  void _optimisticallyRemove(String id) {
    state.maybeMap(
      loaded: (s) {
        final next = s.words.where((w) => w.id != id).toList(growable: false);
        emit(s.copyWith(words: next, pendingWordIds: _pendingWordIds));
      },
      orElse: () {},
    );
  }

  @override
  Future<void> close() {
    _wordsSubscription?.cancel();
    return super.close();
  }
}
