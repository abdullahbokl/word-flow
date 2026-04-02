import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/utils/uuid_generator.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/delete_word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/update_word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_words_paginated.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_state.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_optimistic_updates.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/database/constants.dart';

@injectable
class LibraryCubit extends Cubit<LibraryState> with LibraryOptimisticUpdates {
  LibraryCubit(this._watchWordsPaginated, this._updateWord, this._deleteWord)
    : super(const LibraryState.initial());

  final WatchWordsPaginated _watchWordsPaginated;
  final UpdateWord _updateWord;
  final DeleteWord _deleteWord;

  static const int _pageSize = 50;
  static const int _loadMoreSize = 30;

  StreamSubscription? _wordsSubscription;
  Set<String> _pendingWordIds = <String>{};
  final Map<String, Timer> _debounceTimers = {};
  static const _debounceMs = 2000;

  String? _userId;
  String? _searchQuery;
  WordsFilter _filter = WordsFilter.all;
  int _currentOffset = 0;
  int _totalCount = 0;
  final List<WordEntity> _accumulatedWords = [];

  void init(String? userId) {
    _userId = userId;
    _resetPagination();
    emit(const LibraryState.loading());
    _loadPage(isLoadMore: false);
  }

  void _resetPagination() {
    _wordsSubscription?.cancel();
    _wordsSubscription = null;
    _currentOffset = 0;
    _accumulatedWords.clear();
    _searchQuery = null;
    _filter = WordsFilter.all;
    _totalCount = 0;
  }

  void _loadPage({required bool isLoadMore}) {
    if (isLoadMore) {
      state.maybeMap(
        loaded: (s) => emit(s.copyWith(isLoadingMore: true)),
        orElse: () {},
      );
    }

    final bool? isKnown = switch (_filter) {
      WordsFilter.all => null,
      WordsFilter.known => true,
      WordsFilter.unknown => false,
    };

    final params = WatchWordsPaginatedParams(
      userId: _userId,
      limit: isLoadMore ? _loadMoreSize : _pageSize,
      offset: _currentOffset,
      searchQuery: _searchQuery,
      isKnown: isKnown,
    );

    _wordsSubscription?.cancel();
    _wordsSubscription = _watchWordsPaginated(params).listen((result) {
      result.fold(
        (failure) => _emitLoadedError(failure.message, failure: failure),
        (pageWords) {
          if (isLoadMore) {
            _accumulatedWords.addAll(pageWords);
          } else {
            _accumulatedWords.clear();
            _accumulatedWords.addAll(pageWords);
          }

          final hasMore =
              pageWords.length >= (isLoadMore ? _loadMoreSize : _pageSize);

          if (isLoadMore) {
            _currentOffset += _loadMoreSize;
          } else {
            _currentOffset = pageWords.length;
          }

          state.maybeMap(
            loaded: (s) => emit(
              s.copyWith(
                words: List.unmodifiable(_accumulatedWords),
                hasMore: hasMore,
                isLoadingMore: false,
                totalCount: _totalCount,
                pendingWordIds: _pendingWordIds,
              ),
            ),
            orElse: () => emit(
              LibraryState.loaded(
                words: List.unmodifiable(_accumulatedWords),
                filter: _filter,
                searchQuery: _searchQuery ?? '',
                hasMore: hasMore,
                isLoadingMore: false,
                totalCount: _totalCount,
                pendingWordIds: _pendingWordIds,
              ),
            ),
          );
        },
      );
    });
  }

  void loadMore() {
    state.maybeMap(
      loaded: (s) {
        if (s.isLoadingMore || !s.hasMore) return;
        _loadPage(isLoadMore: true);
      },
      orElse: () {},
    );
  }

  void setFilter(WordsFilter filter) {
    _filter = filter;
    _currentOffset = 0;
    _accumulatedWords.clear();
    _loadPage(isLoadMore: false);
  }

  void setSearch(String query) {
    _searchQuery = query.isEmpty ? null : query;
    _currentOffset = 0;
    _accumulatedWords.clear();
    _loadPage(isLoadMore: false);
  }

  Future<void> toggleKnown(WordEntity word) async {
    if (_debounceTimers.containsKey(word.id)) {
      return;
    }

    final updatedWord = word.copyWith(
      isKnown: !word.isKnown,
      lastUpdated: DateTime.now().toUtc(),
    );
    final prev = word;
    _markPending(word.id);
    _optimisticallyReplace(updatedWord);

    _debounceTimers[word.id] = Timer(
      const Duration(milliseconds: _debounceMs),
      () => _debounceTimers.remove(word.id),
    );

    final result = await _updateWord(updatedWord);
    result.fold((f) {
      _unmarkPending(word.id);
      _optimisticallyReplace(prev);
      _emitLoadedError(f.message, failure: f);
      _debounceTimers[word.id]?.cancel();
      _debounceTimers.remove(word.id);
    }, (_) => _unmarkPending(word.id));
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
    final result = await _deleteWord(DeleteWordParams(id: id, userId: userId));
    result.fold((f) {
      _unmarkPending(id);
      if (prevWord != null) _optimisticallyUpsert(prevWord);
      _emitLoadedError(f.message, failure: f);
    }, (_) => _unmarkPending(id));
  }

  Future<void> addWord(String text, bool isKnown, {String? userId}) async {
    final word = WordEntity(
      id: UuidGenerator.generate(),
      userId: userId ?? guestUserId,
      wordText: text,
      isKnown: isKnown,
      lastUpdated: DateTime.now().toUtc(),
    );
    _markPending(word.id);
    _optimisticallyUpsert(word);
    final result = await _updateWord(word);
    result.fold((f) {
      _unmarkPending(word.id);
      _optimisticallyRemove(word.id);
      _emitLoadedError(f.message, failure: f);
    }, (_) => _unmarkPending(word.id));
  }

  Future<void> updateWord(
    WordEntity word,
    String newText,
    bool newIsKnown,
  ) async {
    final prev = word;
    final updatedWord = word.copyWith(
      wordText: newText,
      isKnown: newIsKnown,
      lastUpdated: DateTime.now().toUtc(),
    );
    _markPending(word.id);
    _optimisticallyReplace(updatedWord);
    final result = await _updateWord(updatedWord);
    result.fold((f) {
      _unmarkPending(word.id);
      _optimisticallyReplace(prev);
      _emitLoadedError(f.message, failure: f);
    }, (_) => _unmarkPending(word.id));
  }

  void clearError() {
    state.maybeMap(
      loaded: (s) {
        if (s.lastError != null || s.failure != null) {
          emit(s.copyWith(lastError: null, failure: null));
        }
      },
      orElse: () {},
    );
  }

  void _markPending(String id) {
    _pendingWordIds = {..._pendingWordIds, id};
    _emitLoadedWithPendingState();
  }

  void _unmarkPending(String id) {
    if (!_pendingWordIds.contains(id)) return;
    _pendingWordIds = {..._pendingWordIds}..remove(id);
    _emitLoadedWithPendingState();
  }

  void _emitLoadedWithPendingState() {
    state.maybeMap(
      loaded: (s) => emit(s.copyWith(pendingWordIds: _pendingWordIds)),
      orElse: () {},
    );
  }

  void _emitLoadedError(String message, {Failure? failure}) {
    state.maybeMap(
      loaded: (s) => emit(s.copyWith(lastError: message, failure: failure)),
      orElse: () => emit(LibraryState.error(message, failure: failure)),
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
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    return super.close();
  }
}
