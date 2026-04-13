part of 'lexicon_bloc.dart';

extension LexiconBlocHandlers on LexiconBloc {
  Future<void> _onLoad(LoadLexicon e, Emitter<LexiconState> emit) async {
    emit(state.copyWith(status: const BlocStatus.loading()));
    await _onFetch(emit: emit, force: true);
    _statsSub ??= _watchStats(const NoParams()).listen((res) =>
        res.fold((_) {}, (s) => add(LexiconEvent.statsUpdateReceived(s))));
  }

  Future<void> _onFetch({
    required Emitter<LexiconState> emit,
    WordFilter? filter,
    WordSort? sort,
    String? query,
    bool force = false,
  }) async {
    final nextFilter = filter ?? state.filter;
    final nextSort = sort ?? state.sort;
    final nextQuery = query ?? state.query;

    if (!force &&
        nextFilter == state.filter &&
        nextSort == state.sort &&
        nextQuery == state.query) {
      return;
    }

    // ✅ Optimistic update - immediate UI response for highlight/query
    emit(state.copyWith(
      status: const BlocStatus.loading(),
      filter: nextFilter,
      sort: nextSort,
      query: nextQuery,
    ));

    final res = await _getWords(
      LexiconQueryParams(
        filter: nextFilter,
        sort: nextSort,
        query: nextQuery,
        limit: LexiconBloc._pageSize,
        offset: 0,
      ),
    ).run();

    res.fold(
      (f) => emit(state.copyWith(status: BlocStatus.failure(error: f.message))),
      (w) {
        emit(state.copyWith(
          status: BlocStatus.success(data: w),
          page: 0,
          hasReachedMax: w.length < LexiconBloc._pageSize,
        ));

        // ✅ Persist only on success
        if (filter != null) unawaited(_cache.saveFilter(filter));
        if (sort != null) unawaited(_cache.saveSort(sort));
      },
    );
  }

  Future<void> _onFetchMore(
      FetchMoreLexicon e, Emitter<LexiconState> emit) async {
    if (state.hasReachedMax || !state.status.isSuccess) return;

    final nextPage = state.page + 1;
    final res = await _getWords(
      LexiconQueryParams(
        filter: state.filter,
        sort: state.sort,
        query: state.query,
        limit: LexiconBloc._pageSize,
        offset: nextPage * LexiconBloc._pageSize,
      ),
    ).run();

    res.fold(
      (f) => null,
      (w) {
        final currentWords = state.status.data as List<WordEntity>;
        emit(state.copyWith(
          status: BlocStatus.success(data: [...currentWords, ...w]),
          page: nextPage,
          hasReachedMax: w.length < LexiconBloc._pageSize,
        ));
      },
    );
  }

  Future<void> _onToggleStatus(
      ToggleWordStatusEvent e, Emitter<LexiconState> emit) async {
    final status = state.status;
    if (!status.isSuccess) return;

    final currentWords = status.data as List<WordEntity>;
    final index = currentWords.indexWhere((w) => w.id == e.wordId);
    if (index == -1) return;

    // Store original state for rollback
    final originalWords = List<WordEntity>.from(currentWords);
    final originalStats = state.stats;

    // Optimistic update - immediate UI response
    final updatedWords = List<WordEntity>.from(currentWords);
    final isKnownNow = !updatedWords[index].isKnown;
    updatedWords[index] = updatedWords[index].copyWith(isKnown: isKnownNow);

    final updatedStats = state.stats.copyWith(
      known: state.stats.known + (isKnownNow ? 1 : -1),
      unknown: state.stats.unknown + (isKnownNow ? -1 : 1),
    );

    emit(state.copyWith(
      status: BlocStatus.success(data: updatedWords),
      stats: updatedStats,
    ));

    // Perform database operation with rollback on failure
    final res = await _toggleWordStatus(e.wordId).run();
    await res.fold(
      (failure) async {
        // Rollback to original state on error
        emit(state.copyWith(
          status: BlocStatus.success(data: originalWords),
          stats: originalStats,
        ));
        add(const LexiconEvent.errorReceived('Failed to update word status'));
      },
      (newWord) {
        // Ensure we're still on a successful state before updating
        if (!state.status.isSuccess) return;

        final latestWords =
            List<WordEntity>.from(state.status.data as List<WordEntity>);
        final latestIndex = latestWords.indexWhere((w) => w.id == newWord.id);
        if (latestIndex != -1) {
          latestWords[latestIndex] = newWord;
          emit(state.copyWith(status: BlocStatus.success(data: latestWords)));
        }
      },
    );
  }

  Future<void> _onDelete(DeleteWordEvent e, Emitter<LexiconState> emit) async {
    final status = state.status;
    if (!status.isSuccess) return;

    final currentWords = status.data as List<WordEntity>;
    final index = currentWords.indexWhere((w) => w.id == e.wordId);
    if (index == -1) return;

    final originalWords = List<WordEntity>.from(currentWords);
    final originalStats = state.stats;

    // Optimistic delete - immediate UI update
    final deletedWord = currentWords[index];
    final updatedStats = state.stats.copyWith(
      total: state.stats.total - 1,
      known: state.stats.known - (deletedWord.isKnown ? 1 : 0),
      unknown: state.stats.unknown - (deletedWord.isKnown ? 0 : 1),
    );

    emit(state.copyWith(
      status: BlocStatus.success(
          data: currentWords.where((w) => w.id != e.wordId).toList()),
      stats: updatedStats,
    ));

    // Perform database operation with rollback on failure
    final res = await _deleteWord(e.wordId).run();
    res.fold(
      (failure) {
        // Rollback on error
        emit(state.copyWith(
          status: BlocStatus.success(data: originalWords),
          stats: originalStats,
        ));
        add(const LexiconEvent.errorReceived('Failed to delete word'));
      },
      (_) {
        // Success - word is deleted, no further action needed
      },
    );
  }

  Future<void> _onRestore(
      RestoreWordEvent e, Emitter<LexiconState> emit) async {
    final optimisticWord = WordEntity(
      id: e.previousId,
      text: e.text,
      frequency: e.previousFrequency,
      isKnown: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final status = state.status;
    if (!status.isSuccess) return;

    final currentWords = status.data as List<WordEntity>;
    final originalWords = List<WordEntity>.from(currentWords);
    final originalStats = state.stats;

    // Optimistic restore - immediate UI update
    final updatedStats = state.stats.copyWith(
      total: state.stats.total + 1,
      unknown: state.stats.unknown + 1,
    );

    emit(state.copyWith(
      status: BlocStatus.success(data: [...currentWords, optimisticWord]),
      stats: updatedStats,
    ));

    final res = await _restoreWord(RestoreWordCommand(
      text: e.text,
      previousId: e.previousId,
      previousFrequency: e.previousFrequency,
      wasFullyDeleted: e.wasFullyDeleted,
    )).run();

    await res.fold(
      (f) async {
        // Rollback on error
        emit(state.copyWith(
          status: BlocStatus.success(data: originalWords),
          stats: originalStats,
        ));
        add(LexiconEvent.errorReceived(f.message));
      },
      (_) async {
        if (!state.status.isSuccess) return;
        final fetched = await _getWordByText(e.text).run();
        fetched.fold(
          (_) {},
          (word) {
            if (word == null) return;
            final latestWords =
                List<WordEntity>.from(state.status.data as List<WordEntity>);
            final idx = latestWords.indexWhere((w) => w.text == word.text);
            if (idx != -1) {
              latestWords[idx] = word;
              emit(state.copyWith(
                  status: BlocStatus.success(data: latestWords)));
            }
          },
        );
      },
    );
  }

  Future<void> _onUpdate(UpdateWordEvent e, Emitter<LexiconState> emit) async {
    final status = state.status;
    if (!status.isSuccess) return;

    final currentWords = status.data as List<WordEntity>;
    final index = currentWords.indexWhere((w) => w.id == e.wordId);
    if (index == -1) return;

    final originalWords = List<WordEntity>.from(currentWords);
    final originalStats = state.stats;

    // Optimistic update - immediate UI feedback
    final updatedWords = List<WordEntity>.from(currentWords);
    final updatedWord = updatedWords[index].copyWith(
      text: e.text,
      meaning: e.meaning,
      description: e.description,
      definitions: e.definitions,
      examples: e.examples,
      translations: e.translations,
      synonyms: e.synonyms,
    );
    updatedWords[index] = updatedWord;
    emit(state.copyWith(status: BlocStatus.success(data: updatedWords)));

    final res = await _updateWord(UpdateWordCommand(
      id: e.wordId,
      text: e.text,
      meaning: e.meaning,
      definitions: e.definitions,
      examples: e.examples,
      translations: e.translations,
      synonyms: e.synonyms,
    )).run();

    res.fold(
      (failure) {
        // Rollback on error
        emit(state.copyWith(
          status: BlocStatus.success(data: originalWords),
          stats: originalStats,
        ));
        add(const LexiconEvent.errorReceived('Failed to update word'));
      },
      (newWord) {
        final latestWords =
            List<WordEntity>.from(state.status.data as List<WordEntity>);
        final latestIndex = latestWords.indexWhere((w) => w.id == newWord.id);
        if (latestIndex != -1) {
          latestWords[latestIndex] = newWord;
          emit(state.copyWith(status: BlocStatus.success(data: latestWords)));
        }
      },
    );
  }

  void _onStatsUpdate(
          LexiconStatsUpdateReceived e, Emitter<LexiconState> emit) =>
      emit(state.copyWith(stats: e.stats));

  void _onErrorReceived(LexiconErrorReceived e, Emitter<LexiconState> emit) =>
      emit(state.copyWith(status: BlocStatus.failure(error: e.message)));
}
