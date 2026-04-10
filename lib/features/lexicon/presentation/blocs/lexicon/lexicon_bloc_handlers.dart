part of 'lexicon_bloc.dart';

extension LexiconBlocHandlers on LexiconBloc {
  Future<void> _onLoad(LoadLexicon e, Emitter<LexiconState> emit) async {
    emit(state.copyWith(status: const BlocStatus.loading()));
    await _onFetch(emit: emit, force: true);
    _statsSub ??= _watchStats(const NoParams()).listen(
        (res) => res.fold((_) {}, (s) => add(LexiconEvent.statsUpdateReceived(s))));
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

    if (!force && nextFilter == state.filter && nextSort == state.sort && nextQuery == state.query) return;

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
      (w) => emit(state.copyWith(
        status: BlocStatus.success(data: w),
        filter: nextFilter,
        sort: nextSort,
        query: nextQuery,
        page: 0,
        hasReachedMax: w.length < LexiconBloc._pageSize,
      )),
    );
  }

  Future<void> _onLoadMore(LoadMoreLexicon e, Emitter<LexiconState> emit) async {
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

  Future<void> _onToggleStatus(ToggleWordStatusEvent e, Emitter<LexiconState> emit) async {
    final status = state.status;
    if (!status.isSuccess) return;

    final currentWords = status.data as List<WordEntity>;
    final index = currentWords.indexWhere((w) => w.id == e.wordId);
    if (index == -1) return;

    final updatedWords = List<WordEntity>.from(currentWords);
    updatedWords[index] = updatedWords[index].copyWith(isKnown: !updatedWords[index].isKnown);
    emit(state.copyWith(status: BlocStatus.success(data: updatedWords)));

    final res = await _toggleWordStatus(e.wordId).run();
    res.fold((_) {}, (newWord) {
      final latestWords = List<WordEntity>.from(state.status.data as List<WordEntity>);
      final latestIndex = latestWords.indexWhere((w) => w.id == newWord.id);
      if (latestIndex != -1) {
        latestWords[latestIndex] = newWord;
        emit(state.copyWith(status: BlocStatus.success(data: latestWords)));
      }
    });
  }

  Future<void> _onDelete(DeleteWordEvent e, Emitter<LexiconState> emit) async {
    final status = state.status;
    if (!status.isSuccess) return;

    final currentWords = status.data as List<WordEntity>;
    emit(state.copyWith(status: BlocStatus.success(data: currentWords.where((w) => w.id != e.wordId).toList())));
    await _deleteWord(e.wordId).run();
  }

  Future<void> _onUpdate(UpdateWordEvent e, Emitter<LexiconState> emit) async {
    final status = state.status;
    if (!status.isSuccess) return;

    final currentWords = status.data as List<WordEntity>;
    final index = currentWords.indexWhere((w) => w.id == e.wordId);
    if (index == -1) return;

    final res = await _updateWord(
      e.wordId,
      text: e.text,
      meaning: e.meaning,
      definitions: e.definitions,
      examples: e.examples,
      translations: e.translations,
      synonyms: e.synonyms,
    ).run();

    res.fold(
      (f) => add(LexiconEvent.errorReceived(f.message)),
      (updatedWord) {
        final latestWords =
            List<WordEntity>.from(state.status.data as List<WordEntity>);
        final latestIndex = latestWords.indexWhere((w) => w.id == updatedWord.id);
        if (latestIndex != -1) {
          latestWords[latestIndex] = updatedWord;
          emit(state.copyWith(status: BlocStatus.success(data: latestWords)));
        }
      },
    );
  }

  void _onStatsUpdate(LexiconStatsUpdateReceived e, Emitter<LexiconState> emit) =>
      emit(state.copyWith(stats: e.stats));

  void _onErrorReceived(LexiconErrorReceived e, Emitter<LexiconState> emit) => emit(state.copyWith(status: BlocStatus.failure(error: e.message)));
}
