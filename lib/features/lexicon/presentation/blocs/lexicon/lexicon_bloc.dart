import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/common/state/bloc_status.dart';
import '../../../domain/usecases/add_word_manually.dart';
import '../../../domain/usecases/delete_word.dart';
import '../../../domain/usecases/toggle_word_status.dart';
import '../../../domain/usecases/update_word.dart';
import '../../../domain/usecases/watch_lexicon_stats.dart';
import '../../../domain/usecases/get_words.dart';
import '../../../domain/entities/word_entity.dart';
import '../../../domain/entities/word_filter.dart';
import '../../../domain/entities/word_sort.dart';
import '../../../../../core/usecase/usecase.dart';
import 'lexicon_event.dart';
import 'lexicon_state.dart';

part 'lexicon_bloc_handlers.dart';

class LexiconBloc extends Bloc<LexiconEvent, LexiconState> {
  LexiconBloc({
    required GetWords getWords,
    required ToggleWordStatus toggleWordStatus,
    required DeleteWord deleteWord,
    required AddWordManually addWordManually,
    required UpdateWord updateWord,
    required WatchLexiconStats watchStats,
  })  : _getWords = getWords,
        _toggleWordStatus = toggleWordStatus,
        _deleteWord = deleteWord,
        _addWordManually = addWordManually,
        _updateWord = updateWord,
        _watchStats = watchStats,
        super(const LexiconState()) {
    on<LoadLexicon>(_onLoad);
    on<LoadMoreLexicon>(_onLoadMore);
    on<LexiconStatsUpdateReceived>(_onStatsUpdate);
    on<LexiconErrorReceived>(_onErrorReceived);
    on<ToggleWordStatusEvent>(_onToggleStatus);
    on<DeleteWordEvent>(_onDelete);
    on<AddWordManuallyEvent>((e, _) async => await _addWordManually(e.word).run());
    on<SearchLexicon>((e, emit) async => await _onFetch(emit: emit, query: e.query));
    on<FilterLexicon>((e, emit) async => await _onFetch(emit: emit, filter: e.filter));
    on<SortLexicon>((e, emit) async => await _onFetch(emit: emit, sort: e.sort));
    on<UpdateWordEvent>((e, _) async => await _updateWord(e.wordId, meaning: e.meaning, description: e.description).run());
  }

  static const _pageSize = 50;
  final GetWords _getWords;
  final WatchLexiconStats _watchStats;
  final ToggleWordStatus _toggleWordStatus;
  final DeleteWord _deleteWord;
  final AddWordManually _addWordManually;
  final UpdateWord _updateWord;
  StreamSubscription? _statsSub;

  @override
  Future<void> close() {
    _statsSub?.cancel();
    return super.close();
  }
}
