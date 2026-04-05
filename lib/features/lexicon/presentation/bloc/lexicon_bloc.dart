import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/state/bloc_status.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';
import '../../domain/usecases/add_word_manually.dart';
import '../../domain/usecases/delete_word.dart';
import '../../domain/usecases/toggle_word_status.dart';
import '../../domain/usecases/update_word.dart';
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
    required UpdateWord updateWord,
    required WatchLexiconStats watchStats,
  })  : _watchWords = watchWords,
        _toggleWordStatus = toggleWordStatus,
        _deleteWord = deleteWord,
        _addWordManually = addWordManually,
        _updateWord = updateWord,
        _watchStats = watchStats,
        super(const LexiconState()) {
    on<LoadLexicon>(_onLoad);
    on<LexiconUpdateReceived>(_onWordsUpdate);
    on<LexiconStatsUpdateReceived>(_onStatsUpdate);
    on<LexiconErrorReceived>(_onErrorReceived);
    on<ToggleWordStatusEvent>((e, _) => _toggleWordStatus(e.wordId).run());
    on<DeleteWordEvent>((e, _) => _deleteWord(e.wordId).run());
    on<AddWordManuallyEvent>((e, _) => _addWordManually(e.word).run());
    on<SearchLexicon>((e, _) => _onWatch(query: e.query));
    on<FilterLexicon>((e, _) => _onWatch(filter: e.filter));
    on<SortLexicon>((e, _) => _onWatch(sort: e.sort));
    on<UpdateWordEvent>((e, _) => _updateWord(e.wordId,
        meaning: e.meaning, description: e.description).run());
  }

  final WatchWords _watchWords;
  final WatchLexiconStats _watchStats;
  final ToggleWordStatus _toggleWordStatus;
  final DeleteWord _deleteWord;
  final AddWordManually _addWordManually;
  final UpdateWord _updateWord;

  StreamSubscription? _wordsSub;
  StreamSubscription? _statsSub;

  void _onLoad(LoadLexicon e, Emitter<LexiconState> emit) {
    emit(state.copyWith(status: const BlocStatus.loading()));
    _onWatch();
    _statsSub ??= _watchStats().listen((res) => res.fold(
        (_) {}, (s) => add(LexiconStatsUpdateReceived(s))));
  }

  void _onWatch({WordFilter? filter, WordSort? sort, String? query}) {
    _wordsSub?.cancel();
    _wordsSub = _watchWords(
      filter: filter ?? state.filter,
      sort: sort ?? state.sort,
      query: query ?? state.query,
    ).listen((res) => res.fold(
          (f) => add(LexiconErrorReceived(f.message)),
          (w) => add(LexiconUpdateReceived(w, filter, sort, query)),
        ));
  }

  void _onWordsUpdate(LexiconUpdateReceived e, Emitter<LexiconState> emit) {
    emit(state.copyWith(
      status: BlocStatus.success(data: e.words),
      filter: e.filter,
      sort: e.sort,
      query: e.query,
    ));
  }

  void _onStatsUpdate(LexiconStatsUpdateReceived e, Emitter<LexiconState> emit) {
    emit(state.copyWith(stats: e.stats));
  }

  void _onErrorReceived(LexiconErrorReceived e, Emitter<LexiconState> emit) {
    emit(state.copyWith(status: BlocStatus.failure(error: e.message)));
  }

  @override
  Future<void> close() {
    _wordsSub?.cancel();
    _statsSub?.cancel();
    return super.close();
  }
}
