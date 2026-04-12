import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexitrack/core/common/state/bloc_status.dart';
import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/lexicon/domain/commands/word_commands.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_filter.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_sort.dart';
import 'package:lexitrack/features/lexicon/domain/repositories/lexicon_preferences.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/add_word_manually.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/delete_word.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/get_word_by_text.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/get_words.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/restore_word.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/toggle_word_status.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/update_word.dart';
import 'package:lexitrack/features/lexicon/domain/usecases/watch_lexicon_stats.dart';
import 'package:lexitrack/features/lexicon/presentation/blocs/lexicon/lexicon_event.dart';
import 'package:lexitrack/features/lexicon/presentation/blocs/lexicon/lexicon_state.dart';

export 'lexicon_event.dart';
export 'lexicon_state.dart';

part 'lexicon_bloc_handlers.dart';

class LexiconBloc extends Bloc<LexiconEvent, LexiconState> {
  LexiconBloc({
    required GetWords getWords,
    required ToggleWordStatus toggleWordStatus,
    required DeleteWord deleteWord,
    required AddWordManually addWordManually,
    required UpdateWord updateWord,
    required WatchLexiconStats watchStats,
    required LexiconPreferences cache,
    required RestoreWord restoreWord,
    required GetWordByText getWordByText,
  })  : _getWords = getWords,
        _toggleWordStatus = toggleWordStatus,
        _deleteWord = deleteWord,
        _addWordManually = addWordManually,
        _updateWord = updateWord,
        _watchStats = watchStats,
        _cache = cache,
        _restoreWord = restoreWord,
        _getWordByText = getWordByText,
        super(LexiconState(
          filter: cache.getFilter(),
          sort: cache.getSort(),
        )) {
    on<LoadLexicon>(_onLoad);
    on<LoadMoreLexicon>(_onLoadMore);
    on<LexiconStatsUpdateReceived>(_onStatsUpdate);
    on<LexiconErrorReceived>(_onErrorReceived);
    on<ToggleWordStatusEvent>(_onToggleStatus);
    on<DeleteWordEvent>(_onDelete);
    on<RestoreWordEvent>(_onRestore);
    on<AddWordManuallyEvent>((e, emit) async {
      final res = await _addWordManually(AddWordCommand(text: e.word)).run();
      res.fold(
        (f) => add(LexiconEvent.errorReceived(f.message)),
        (_) => add(const LoadLexicon()),
      );
    });
    on<SearchLexicon>((e, emit) => _onFetch(emit: emit, query: e.query),
        transformer: restartable());
    on<FilterLexicon>((e, emit) => _onFetch(emit: emit, filter: e.filter),
        transformer: restartable());
    on<SortLexicon>((e, emit) => _onFetch(emit: emit, sort: e.sort),
        transformer: restartable());
    on<UpdateWordEvent>(_onUpdate);
  }

  static const _pageSize = 50;
  final GetWords _getWords;
  final WatchLexiconStats _watchStats;
  final ToggleWordStatus _toggleWordStatus;
  final DeleteWord _deleteWord;
  final AddWordManually _addWordManually;
  final UpdateWord _updateWord;
  final RestoreWord _restoreWord;
  final GetWordByText _getWordByText;
  final LexiconPreferences _cache;
  StreamSubscription? _statsSub;

  @override
  Future<void> close() async {
    await _statsSub?.cancel();
    return super.close();
  }
}
