import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';
import '../../domain/usecases/add_word_manually.dart';
import '../../domain/usecases/delete_word.dart';
import '../../domain/usecases/toggle_word_status.dart';
import '../../domain/usecases/watch_lexicon_stats.dart';
import '../../domain/usecases/watch_words.dart';
import 'lexicon_event.dart';
import 'lexicon_state.dart';

class LexiconBloc extends Bloc<LexiconEvent, LexiconState> {
  LexiconBloc({
    required WatchWords watchWords,
    required ToggleWordStatus toggleWordStatus,
    required DeleteWord deleteWord,
    required AddWordManually addWordManually,
    required WatchLexiconStats watchStats,
  })  : _watchWords = watchWords,
        _toggleWordStatus = toggleWordStatus,
        _deleteWord = deleteWord,
        _addWordManually = addWordManually,
        _watchStats = watchStats,
        super(const LexiconInitial()) {
    on<LoadLexicon>(_onLoad);
    on<LexiconUpdateReceived>(_onWordsUpdate);
    on<LexiconStatsUpdateReceived>(_onStatsUpdate);
    on<LexiconErrorReceived>(_onErrorReceived);
    on<ToggleWordStatusEvent>(_onToggle);
    on<DeleteWordEvent>(_onDelete);
    on<SearchLexicon>(_onSearch);
    on<FilterLexicon>(_onFilter);
    on<SortLexicon>(_onSort);
    on<AddWordManuallyEvent>(_onAdd);
  }

  final WatchWords _watchWords;
  final WatchLexiconStats _watchStats;
  final ToggleWordStatus _toggleWordStatus;
  final DeleteWord _deleteWord;
  final AddWordManually _addWordManually;

  StreamSubscription? _wordsSubscription;
  StreamSubscription? _statsSubscription;

  WordFilter _activeFilter = WordFilter.all;
  WordSort _activeSort = WordSort.frequencyDesc;
  String _activeQuery = '';
  LexiconStats _currentStats = const LexiconStats.empty();

  Future<void> _onLoad(LoadLexicon e, Emitter<LexiconState> emit) async {
    emit(const LexiconLoading());
    _startWatching();
  }

  void _startWatching() {
    _wordsSubscription?.cancel();
    _statsSubscription?.cancel();

    _wordsSubscription = _watchWords(
      filter: _activeFilter,
      sort: _activeSort,
      query: _activeQuery,
    ).listen((result) {
      result.fold(
        (f) => add(LexiconErrorReceived(f.message)),
        (words) => add(LexiconUpdateReceived(words)),
      );
    });

    _statsSubscription = _watchStats().listen((result) {
      result.fold(
        (_) {}, // Ignore stats errors for now
        (stats) => add(LexiconStatsUpdateReceived(stats)),
      );
    });
  }

  void _onWordsUpdate(LexiconUpdateReceived e, Emitter<LexiconState> emit) {
    emit(LexiconLoaded(
      words: e.words,
      filter: _activeFilter,
      sort: _activeSort,
      query: _activeQuery,
      stats: _currentStats,
    ));
  }

  void _onStatsUpdate(LexiconStatsUpdateReceived e, Emitter<LexiconState> emit) {
    _currentStats = e.stats;
    if (state is LexiconLoaded) {
      emit((state as LexiconLoaded).copyWith(stats: e.stats));
    }
  }

  void _onErrorReceived(LexiconErrorReceived e, Emitter<LexiconState> emit) {
    emit(LexiconFailure(e.message));
  }

  Future<void> _onToggle(
    ToggleWordStatusEvent e,
    Emitter<LexiconState> emit,
  ) async {
    // Optimistic UI could be added here, but with local DB it's fast enough
    await _toggleWordStatus(e.wordId).run();
  }

  Future<void> _onDelete(
    DeleteWordEvent e,
    Emitter<LexiconState> emit,
  ) async {
    await _deleteWord(e.wordId).run();
  }

  Future<void> _onSearch(
    SearchLexicon e,
    Emitter<LexiconState> emit,
  ) async {
    _activeQuery = e.query;
    _startWatching();
  }

  Future<void> _onFilter(
    FilterLexicon e,
    Emitter<LexiconState> emit,
  ) async {
    _activeFilter = e.filter;
    _startWatching();
  }

  Future<void> _onAdd(
    AddWordManuallyEvent e,
    Emitter<LexiconState> emit,
  ) async {
    await _addWordManually(e.word).run();
  }

  void _onSort(
    SortLexicon e,
    Emitter<LexiconState> emit,
  ) {
    _activeSort = e.sort;
    _startWatching();
  }

  @override
  Future<void> close() {
    _wordsSubscription?.cancel();
    _statsSubscription?.cancel();
    return super.close();
  }
}
