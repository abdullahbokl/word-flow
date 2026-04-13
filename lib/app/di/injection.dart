import 'package:get_it/get_it.dart';
import 'package:wordflow/core/backup/backup_repository.dart';
import 'package:wordflow/core/backup/backup_repository_impl.dart';
import 'package:wordflow/core/cache/local_cache.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/core/theme/theme_cubit.dart';
import 'package:wordflow/features/excluded_words/data/datasources/excluded_words_local_data_source.dart';
import 'package:wordflow/features/excluded_words/data/datasources/excluded_words_local_data_source_impl.dart';
import 'package:wordflow/features/excluded_words/data/repositories/excluded_words_repository_impl.dart';
import 'package:wordflow/features/excluded_words/domain/repositories/excluded_words_repository.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/add_excluded_word.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/delete_excluded_word.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/get_excluded_words.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/initialize_default_excluded_words.dart';
import 'package:wordflow/features/excluded_words/domain/usecases/update_excluded_word.dart';
import 'package:wordflow/features/excluded_words/presentation/cubit/excluded_words_cubit.dart';
import 'package:wordflow/features/history/data/datasources/history_local_ds.dart';
import 'package:wordflow/features/history/data/repositories/history_repository_impl.dart';
import 'package:wordflow/features/history/domain/repositories/history_repository.dart';
import 'package:wordflow/features/history/domain/usecases/delete_history_item.dart';
import 'package:wordflow/features/history/domain/usecases/get_history.dart';
import 'package:wordflow/features/history/domain/usecases/get_history_detail.dart';
import 'package:wordflow/features/history/domain/usecases/watch_history.dart';
import 'package:wordflow/features/history/domain/usecases/watch_history_detail.dart';
import 'package:wordflow/features/history/presentation/blocs/history/history_bloc.dart';
import 'package:wordflow/features/history/presentation/blocs/history_detail/history_detail_bloc.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_cache.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_local_ds.dart';
import 'package:wordflow/features/lexicon/data/datasources/lexicon_local_ds_impl.dart';
import 'package:wordflow/features/lexicon/data/repositories/lexicon_repository_impl.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_preferences.dart';
import 'package:wordflow/features/lexicon/domain/repositories/lexicon_repository.dart';
import 'package:wordflow/features/lexicon/domain/usecases/add_word_manually.dart';
import 'package:wordflow/features/lexicon/domain/usecases/delete_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/get_lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/usecases/get_word_by_text.dart';
import 'package:wordflow/features/lexicon/domain/usecases/get_words.dart';
import 'package:wordflow/features/lexicon/domain/usecases/restore_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/toggle_word_status.dart';
import 'package:wordflow/features/lexicon/domain/usecases/update_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/watch_lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/usecases/watch_words.dart';
import 'package:wordflow/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:wordflow/features/settings/presentation/blocs/backup/backup_bloc.dart';
import 'package:wordflow/features/text_analyzer/data/datasources/analyzer_local_ds.dart';
import 'package:wordflow/features/text_analyzer/data/datasources/analyzer_local_ds_impl.dart';
import 'package:wordflow/features/text_analyzer/data/repositories/analyzer_repository_impl.dart';
import 'package:wordflow/features/text_analyzer/domain/repositories/analyzer_repository.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/analyze_text.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/get_analysis_result.dart';
import 'package:wordflow/features/text_analyzer/domain/usecases/update_analysis_counts.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Core
  final db = AppDatabase();
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<AppDatabase>(db)
    ..registerSingleton<LocalCache>(LocalCacheImpl(prefs))
    ..registerFactory(ThemeCubit.new)
    // Features - Lexicon
    ..registerLazySingleton<LexiconLocalDataSource>(
        () => LexiconLocalDataSourceImpl(sl(), sl()))
    ..registerLazySingleton<LexiconRepository>(
        () => LexiconRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetWords(sl()))
    ..registerLazySingleton(() => ToggleWordStatus(sl()))
    ..registerLazySingleton(() => DeleteWord(sl()))
    ..registerLazySingleton(() => AddWordManually(sl()))
    ..registerLazySingleton(() => RestoreWord(sl()))
    ..registerLazySingleton(() => UpdateWord(sl()))
    ..registerLazySingleton(() => GetLexiconStats(sl()))
    ..registerLazySingleton(() => GetWordByText(sl()))
    ..registerLazySingleton(() => WatchWords(sl()))
    ..registerLazySingleton(() => WatchLexiconStats(sl()))
    ..registerLazySingleton<LexiconPreferences>(() => LexiconCache(sl()))
    ..registerFactory(() => LexiconBloc(
          getWords: sl(),
          toggleWordStatus: sl(),
          deleteWord: sl(),
          addWordManually: sl(),
          updateWord: sl(),
          watchStats: sl(),
          cache: sl(),
          restoreWord: sl(),
          getWordByText: sl(),
        ))

    // Features - Text Analyzer
    ..registerLazySingleton<AnalyzerLocalDataSource>(
        () => AnalyzerLocalDataSourceImpl(sl()))
    ..registerLazySingleton<AnalyzerRepository>(
        () => AnalyzerRepositoryImpl(sl()))
    ..registerLazySingleton(() => AnalyzeText(sl()))
    ..registerLazySingleton(() => GetAnalysisResult(sl()))
    ..registerLazySingleton(() => UpdateAnalysisCounts(sl()))
    ..registerFactory(() => AnalyzerBloc(
          analyzeText: sl(),
          getAnalysisResult: sl(),
          updateAnalysisCounts: sl(),
          toggleWordStatus: sl(),
        ))

    // Features - History
    ..registerLazySingleton<HistoryLocalDataSource>(
        () => HistoryLocalDataSourceImpl(sl()))
    ..registerLazySingleton<HistoryRepository>(
        () => HistoryRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetHistory(sl()))
    ..registerLazySingleton(() => WatchHistory(sl()))
    ..registerLazySingleton(() => DeleteHistoryItem(sl()))
    ..registerLazySingleton(() => GetHistoryDetail(sl()))
    ..registerLazySingleton(() => WatchHistoryDetail(sl()))
    ..registerFactory(() => HistoryBloc(
          watchHistory: sl(),
          deleteHistoryItem: sl(),
        ))
    ..registerFactory(() => HistoryDetailBloc(sl(), sl()))

    // Features - Settings / Backup
    ..registerLazySingleton<BackupRepository>(() => BackupRepositoryImpl(sl()))
    ..registerFactory(() => BackupBloc(sl()))

    // Features - Excluded Words
    ..registerLazySingleton<ExcludedWordsLocalDataSource>(
        () => ExcludedWordsLocalDataSourceImpl(sl()))
    ..registerLazySingleton<ExcludedWordsRepository>(
        () => ExcludedWordsRepositoryImpl(localDataSource: sl()))
    ..registerLazySingleton(() => GetExcludedWordsUseCase(sl()))
    ..registerLazySingleton(() => AddExcludedWordUseCase(sl()))
    ..registerLazySingleton(() => UpdateExcludedWordUseCase(sl()))
    ..registerLazySingleton(() => DeleteExcludedWordUseCase(sl()))
    ..registerLazySingleton(() => InitializeDefaultExcludedWordsUseCase(sl()))
    ..registerFactory(() => ExcludedWordsCubit(
          getExcludedWords: sl(),
          addExcludedWord: sl(),
          updateExcludedWord: sl(),
          deleteExcludedWord: sl(),
          initializeDefaults: sl(),
        ));
}
