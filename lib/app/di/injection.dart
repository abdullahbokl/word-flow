import 'package:get_it/get_it.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/theme_cubit.dart';
import '../../features/history/data/datasources/history_local_ds.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/delete_history_item.dart';
import '../../features/history/domain/usecases/get_history.dart';
import '../../features/history/domain/usecases/get_history_detail.dart';
import '../../features/history/domain/usecases/watch_history.dart';
import '../../features/history/domain/usecases/watch_history_detail.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/history/presentation/bloc/history_detail_bloc.dart';
import '../../features/lexicon/data/datasources/lexicon_local_ds.dart';
import '../../features/lexicon/data/repositories/lexicon_repository_impl.dart';
import '../../features/lexicon/domain/repositories/lexicon_repository.dart';
import '../../features/lexicon/domain/usecases/add_word_manually.dart';
import '../../features/lexicon/domain/usecases/delete_word.dart';
import '../../features/lexicon/domain/usecases/get_lexicon_stats.dart';
import '../../features/lexicon/domain/usecases/get_words.dart';
import '../../features/lexicon/domain/usecases/toggle_word_status.dart';
import '../../features/lexicon/domain/usecases/watch_lexicon_stats.dart';
import '../../features/lexicon/domain/usecases/watch_words.dart';
import '../../features/lexicon/presentation/bloc/lexicon_bloc.dart';
import '../../features/text_analyzer/data/datasources/analyzer_local_ds.dart';
import '../../features/text_analyzer/data/repositories/analyzer_repository_impl.dart';
import '../../features/text_analyzer/domain/repositories/analyzer_repository.dart';
import '../../features/text_analyzer/domain/usecases/analyze_text.dart';
import '../../features/text_analyzer/presentation/bloc/analyzer_bloc.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Core
  final db = AppDatabase();
  sl.registerSingleton<AppDatabase>(db);
  sl.registerFactory(() => ThemeCubit());

  // Features - Lexicon
  sl.registerLazySingleton<LexiconLocalDataSource>(
      () => LexiconLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<LexiconRepository>(
      () => LexiconRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetWords(sl()));
  sl.registerLazySingleton(() => ToggleWordStatus(sl()));
  sl.registerLazySingleton(() => DeleteWord(sl()));
  sl.registerLazySingleton(() => AddWordManually(sl()));
  sl.registerLazySingleton(() => GetLexiconStats(sl()));
  sl.registerLazySingleton(() => WatchWords(sl()));
  sl.registerLazySingleton(() => WatchLexiconStats(sl()));
  sl.registerFactory(() => LexiconBloc(
        watchWords: sl(),
        toggleWordStatus: sl(),
        deleteWord: sl(),
        addWordManually: sl(),
        watchStats: sl(),
      ));

  // Features - Text Analyzer
  sl.registerLazySingleton<AnalyzerLocalDataSource>(
      () => AnalyzerLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AnalyzerRepository>(
      () => AnalyzerRepositoryImpl(sl()));
  sl.registerLazySingleton(() => AnalyzeText(sl()));
  sl.registerFactory(() => AnalyzerBloc(analyzeText: sl()));

  // Features - History
  sl.registerLazySingleton<HistoryLocalDataSource>(
      () => HistoryLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetHistory(sl()));
  sl.registerLazySingleton(() => WatchHistory(sl()));
  sl.registerLazySingleton(() => DeleteHistoryItem(sl()));
  sl.registerLazySingleton(() => GetHistoryDetail(sl()));
  sl.registerLazySingleton(() => WatchHistoryDetail(sl()));
  sl.registerFactory(() => HistoryBloc(
        watchHistory: sl(),
        deleteHistoryItem: sl(),
      ));
  sl.registerFactory(() => HistoryDetailBloc(sl()));
}
