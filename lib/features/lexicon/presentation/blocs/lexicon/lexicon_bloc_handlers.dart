part of 'lexicon_bloc.dart';

extension LexiconBlocHandlers on LexiconBloc {
  Future<void> _onLoad(LoadLexicon e, Emitter<LexiconState> emit) async {
    emit(state.copyWith(status: const BlocStatus.loading()));

    // Cancel existing subscriptions
    await _wordsSub?.cancel();
    await _statsSub?.cancel();

    // Start watching words
    _wordsSub = _watchWords(LexiconQueryParams(
      filter: state.filter,
      sort: state.sort,
      query: state.query,
    )).listen((res) {
      res.fold(
        (f) => add(LexiconEvent.errorReceived(f.message)),
        (words) => add(LexiconEvent.updateReceived(words: words)),
      );
    });

    // Start watching stats
    _statsSub = _watchStats(const NoParams()).listen((res) {
      res.fold(
        (_) {},
        (stats) => add(LexiconEvent.statsUpdateReceived(stats)),
      );
    });
  }

  void _onUpdateReceived(LexiconUpdateReceived e, Emitter<LexiconState> emit) {
    emit(state.copyWith(
      status: BlocStatus.success(data: e.words),
      hasReachedMax: e.words.length < LexiconBloc._pageSize,
      page: 0,
    ));
  }

  Future<void> _onSearch(SearchLexicon e, Emitter<LexiconState> emit) async {
    if (e.query == state.query) return;

    emit(state.copyWith(
      query: e.query,
      status: const BlocStatus.loading(),
    ));

    await _restartWordsSubscription(query: e.query);
  }

  Future<void> _onFilter(FilterLexicon e, Emitter<LexiconState> emit) async {
    if (e.filter == state.filter) return;

    emit(state.copyWith(
      filter: e.filter,
      status: const BlocStatus.loading(),
    ));

    unawaited(_cache.saveFilter(e.filter));
    await _restartWordsSubscription(filter: e.filter);
  }

  Future<void> _onSort(SortLexicon e, Emitter<LexiconState> emit) async {
    if (e.sort == state.sort) return;

    emit(state.copyWith(
      sort: e.sort,
      status: const BlocStatus.loading(),
    ));

    unawaited(_cache.saveSort(e.sort));
    await _restartWordsSubscription(sort: e.sort);
  }

  Future<void> _restartWordsSubscription({
    WordFilter? filter,
    WordSort? sort,
    String? query,
  }) async {
    await _wordsSub?.cancel();
    _wordsSub = _watchWords(LexiconQueryParams(
      filter: filter ?? state.filter,
      sort: sort ?? state.sort,
      query: query ?? state.query,
    )).listen((res) {
      res.fold(
        (f) => add(LexiconEvent.errorReceived(f.message)),
        (words) => add(LexiconEvent.updateReceived(words: words)),
      );
    });
  }

  Future<void> _onFetchMore(
      FetchMoreLexicon e, Emitter<LexiconState> emit) async {
    if (state.hasReachedMax || !state.status.isSuccess) return;

    final nextPage = state.page + 1;
    final res = await _getWords(LexiconQueryParams(
      filter: state.filter,
      sort: state.sort,
      query: state.query,
      limit: LexiconBloc._pageSize,
      offset: nextPage * LexiconBloc._pageSize,
    )).run();

    res.fold(
      (_) {},
      (newWords) {
        final currentWords = state.status.data ?? [];
        emit(state.copyWith(
          status: BlocStatus.success(data: [...currentWords, ...newWords]),
          page: nextPage,
          hasReachedMax: newWords.length < LexiconBloc._pageSize,
        ));
      },
    );
  }

  Future<void> _onToggleStatus(
      ToggleWordStatusEvent e, Emitter<LexiconState> emit) async {
    final res = await _toggleWordStatus(e.wordId).run();
    res.fold(
      (f) => add(LexiconEvent.errorReceived(f.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onDelete(DeleteWordEvent e, Emitter<LexiconState> emit) async {
    final res = await _deleteWord(e.wordId).run();
    res.fold(
      (f) => add(LexiconEvent.errorReceived(f.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onExclude(
      ExcludeWordEvent e, Emitter<LexiconState> emit) async {
    final res = await _updateWord(UpdateWordCommand(
      id: e.wordId,
      isExcluded: true,
    )).run();
    res.fold(
      (f) => add(LexiconEvent.errorReceived(f.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onRestore(
      RestoreWordEvent e, Emitter<LexiconState> emit) async {
    final res = await _restoreWord(RestoreWordCommand(
      text: e.text,
      previousId: e.previousId,
      previousFrequency: e.previousFrequency,
      wasFullyDeleted: e.wasFullyDeleted,
    )).run();

    res.fold(
      (f) => add(LexiconEvent.errorReceived(f.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onAddManually(
      AddWordManuallyEvent e, Emitter<LexiconState> emit) async {
    final res = await _addWordManually(AddWordCommand(text: e.word)).run();
    res.fold(
      (f) => add(LexiconEvent.errorReceived(f.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onUpdate(UpdateWordEvent e, Emitter<LexiconState> emit) async {
    final res = await _updateWord(UpdateWordCommand(
      id: e.wordId,
      text: e.text,
      meaning: e.meaning,
      description: e.description,
      definitions: e.definitions,
      examples: e.examples,
      translations: e.translations,
      synonyms: e.synonyms,
    )).run();

    res.fold(
      (f) => add(LexiconEvent.errorReceived(f.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onUpdateCategory(
      UpdateWordCategory e, Emitter<LexiconState> emit) async {
    final res = await _updateWord(UpdateWordCommand(
      id: e.wordId,
      category: e.category.name,
    )).run();

    res.fold(
      (f) => add(LexiconEvent.errorReceived(f.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onStartReview(StartReview e, Emitter<LexiconState> emit) async {
    // SRS logic will be implemented in Task 12/13.
    // For now, we just ensure the event is handled.
  }

  void _onStatsUpdate(
          LexiconStatsUpdateReceived e, Emitter<LexiconState> emit) =>
      emit(state.copyWith(stats: e.stats));

  void _onErrorReceived(LexiconErrorReceived e, Emitter<LexiconState> emit) =>
      emit(state.copyWith(status: BlocStatus.failure(error: e.message)));
}
