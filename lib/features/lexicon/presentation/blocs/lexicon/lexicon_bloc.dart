import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wordflow/core/common/state/bloc_status.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/lexicon/domain/commands/word_commands.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_sort.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_preferences.dart';
import 'package:wordflow/features/lexicon/domain/usecases/add_word_manually.dart';
import 'package:wordflow/features/lexicon/domain/usecases/delete_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/get_words.dart';
import 'package:wordflow/features/lexicon/domain/usecases/restore_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/toggle_word_status.dart';
import 'package:wordflow/features/lexicon/domain/usecases/update_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/watch_lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/usecases/watch_words.dart';
import 'package:wordflow/features/lexicon/presentation/blocs/lexicon/lexicon_event.dart';
import 'package:wordflow/features/lexicon/presentation/blocs/lexicon/lexicon_state.dart';

export 'lexicon_event.dart';
export 'lexicon_state.dart';

part 'lexicon_bloc_handlers.dart';

class LexiconBloc extends Bloc<LexiconEvent, LexiconState> {
  LexiconBloc({
    required GetWords getWords,
    required WatchWords watchWords,
    required ToggleWordStatus toggleWordStatus,
    required DeleteWord deleteWord,
    required AddWordManually addWordManually,
    required UpdateWord updateWord,
    required WatchLexiconStats watchStats,
    required LexiconPreferences cache,
    required RestoreWord restoreWord,
  })  : _getWords = getWords,
        _watchWords = watchWords,
        _toggleWordStatus = toggleWordStatus,
        _deleteWord = deleteWord,
        _addWordManually = addWordManually,
        _updateWord = updateWord,
        _watchStats = watchStats,
        _cache = cache,
        _restoreWord = restoreWord,
        super(LexiconState(
          filter: cache.getFilter(),
          sort: cache.getSort(),
        )) {
    on<LoadLexicon>(_onLoad);
    on<LexiconUpdateReceived>(_onUpdateReceived);
    on<LexiconStatsUpdateReceived>(_onStatsUpdate);
    on<LexiconErrorReceived>(_onErrorReceived);

    on<ToggleWordStatusEvent>(_onToggleStatus, transformer: restartable());
    on<DeleteWordEvent>(_onDelete, transformer: restartable());
    on<ExcludeWordEvent>(_onExclude, transformer: restartable());
    on<RestoreWordEvent>(_onRestore, transformer: restartable());
    on<AddWordManuallyEvent>(_onAddManually, transformer: restartable());
    on<UpdateWordEvent>(_onUpdate, transformer: restartable());
    on<UpdateWordCategory>(_onUpdateCategory, transformer: restartable());
    on<StartReview>(_onStartReview, transformer: restartable());

    on<SearchLexicon>(_onSearch, transformer: _debouncedRestartable());
    on<FilterLexicon>(_onFilter, transformer: restartable());
    on<SortLexicon>(_onSort, transformer: restartable());

    on<FetchMoreLexicon>(_onFetchMore);
  }

  EventTransformer<T> _debouncedRestartable<T>() {
    return (events, mapper) => restartable<T>()(
          events.debounceTime(const Duration(milliseconds: 300)),
          mapper,
        );
  }

  static const _pageSize = 50;
  final GetWords _getWords;
  final WatchWords _watchWords;
  final WatchLexiconStats _watchStats;
  final ToggleWordStatus _toggleWordStatus;
  final DeleteWord _deleteWord;
  final AddWordManually _addWordManually;
  final UpdateWord _updateWord;
  final RestoreWord _restoreWord;
  final LexiconPreferences _cache;

  StreamSubscription? _wordsSub;
  StreamSubscription? _statsSub;

  @override
  Future<void> close() async {
    await _wordsSub?.cancel();
    await _statsSub?.cancel();
    return super.close();
  }
}
