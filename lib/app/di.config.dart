// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../core/database/app_database.dart' as _i935;
import '../core/database/write_queue.dart' as _i470;
import '../core/network/dio_client.dart' as _i393;
import '../core/sync/connectivity_monitor.dart' as _i862;
import '../core/sync/sync_service.dart' as _i957;
import '../features/auth/data/datasources/auth_remote_source.dart' as _i303;
import '../features/auth/data/repositories/auth_repository_impl.dart' as _i570;
import '../features/auth/domain/repositories/auth_repository.dart' as _i869;
import '../features/auth/domain/usecases/sign_in_with_email.dart' as _i33;
import '../features/auth/domain/usecases/sign_out.dart' as _i472;
import '../features/auth/domain/usecases/sign_up_with_email.dart' as _i588;
import '../features/auth/presentation/cubit/auth_cubit.dart' as _i70;
import '../features/words/data/datasources/sync_local_source.dart' as _i1011;
import '../features/words/data/datasources/word_local_source.dart' as _i621;
import '../features/words/data/datasources/word_remote_source.dart' as _i224;
import '../features/words/data/repositories/sync_repository_impl.dart' as _i107;
import '../features/words/data/repositories/word_repository_impl.dart' as _i296;
import '../features/words/data/services/isolate_text_analysis_service.dart'
    as _i694;
import '../features/words/domain/repositories/sync_repository.dart' as _i899;
import '../features/words/domain/repositories/word_repository.dart' as _i994;
import '../features/words/domain/services/text_analysis_service.dart' as _i311;
import '../features/words/domain/usecases/adopt_guest_words.dart' as _i915;
import '../features/words/domain/usecases/clear_local_words.dart' as _i535;
import '../features/words/domain/usecases/delete_word.dart' as _i774;
import '../features/words/domain/usecases/get_guest_words_count.dart' as _i565;
import '../features/words/domain/usecases/get_known_word_texts.dart' as _i902;
import '../features/words/domain/usecases/get_known_words.dart' as _i552;
import '../features/words/domain/usecases/get_pending_count.dart' as _i75;
import '../features/words/domain/usecases/process_script.dart' as _i69;
import '../features/words/domain/usecases/save_processed_words.dart' as _i455;
import '../features/words/domain/usecases/sync_pending_words.dart' as _i796;
import '../features/words/domain/usecases/toggle_known_word.dart' as _i646;
import '../features/words/domain/usecases/update_word.dart' as _i906;
import '../features/words/domain/usecases/watch_pending_count.dart' as _i613;
import '../features/words/domain/usecases/watch_words.dart' as _i226;
import '../features/words/presentation/cubit/library_cubit.dart' as _i7;
import '../features/words/presentation/cubit/sync_cubit.dart' as _i557;
import '../features/words/presentation/cubit/workspace_cubit.dart' as _i996;
import 'di.dart' as _i913;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i862.ConnectivityMonitor>(
      () => _i862.ConnectivityMonitor(),
    );
    gh.lazySingleton<_i935.WordFlowDatabase>(() => _i935.WordFlowDatabase());
    gh.lazySingleton<_i470.LocalWriteQueue>(() => _i470.LocalWriteQueue());
    gh.lazySingleton<_i311.TextAnalysisService>(
      () => _i694.IsolateTextAnalysisService(),
    );
    gh.lazySingleton<_i1011.SyncLocalSource>(
      () => _i1011.SyncLocalSourceImpl(gh<_i935.WordFlowDatabase>()),
    );
    gh.lazySingleton<_i393.DioClient>(
      () => _i393.DioClient(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i621.WordLocalSource>(
      () => _i621.WordLocalSourceImpl(gh<_i935.WordFlowDatabase>()),
    );
    gh.lazySingleton<_i303.AuthRemoteSource>(
      () => _i303.AuthRemoteSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i224.WordRemoteSource>(
      () => _i224.WordRemoteSourceImpl(gh<_i393.DioClient>()),
    );
    gh.lazySingleton<_i899.SyncRepository>(
      () => _i107.SyncRepositoryImpl(
        gh<_i621.WordLocalSource>(),
        gh<_i1011.SyncLocalSource>(),
        gh<_i224.WordRemoteSource>(),
      ),
    );
    gh.lazySingleton<_i994.WordRepository>(
      () => _i296.WordRepositoryImpl(
        gh<_i621.WordLocalSource>(),
        gh<_i1011.SyncLocalSource>(),
        gh<_i470.LocalWriteQueue>(),
      ),
    );
    gh.lazySingleton<_i957.SyncService>(
      () => _i957.SyncService(
        gh<_i899.SyncRepository>(),
        gh<_i862.ConnectivityMonitor>(),
      ),
    );
    gh.lazySingleton<_i869.AuthRepository>(
      () => _i570.AuthRepositoryImpl(gh<_i303.AuthRemoteSource>()),
    );
    gh.lazySingleton<_i33.SignInWithEmail>(
      () => _i33.SignInWithEmail(gh<_i869.AuthRepository>()),
    );
    gh.lazySingleton<_i472.SignOut>(
      () => _i472.SignOut(gh<_i869.AuthRepository>()),
    );
    gh.lazySingleton<_i588.SignUpWithEmail>(
      () => _i588.SignUpWithEmail(gh<_i869.AuthRepository>()),
    );
    gh.lazySingleton<_i69.ProcessScript>(
      () => _i69.ProcessScript(
        gh<_i994.WordRepository>(),
        gh<_i311.TextAnalysisService>(),
      ),
    );
    gh.lazySingleton<_i915.AdoptGuestWords>(
      () => _i915.AdoptGuestWords(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i902.GetKnownWordTexts>(
      () => _i902.GetKnownWordTexts(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i226.WatchWords>(
      () => _i226.WatchWords(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i774.DeleteWord>(
      () => _i774.DeleteWord(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i552.GetKnownWords>(
      () => _i552.GetKnownWords(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i455.SaveProcessedWords>(
      () => _i455.SaveProcessedWords(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i535.ClearLocalWords>(
      () => _i535.ClearLocalWords(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i906.UpdateWord>(
      () => _i906.UpdateWord(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i565.GetGuestWordsCount>(
      () => _i565.GetGuestWordsCount(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i646.ToggleKnownWord>(
      () => _i646.ToggleKnownWord(gh<_i994.WordRepository>()),
    );
    gh.lazySingleton<_i613.WatchPendingCount>(
      () => _i613.WatchPendingCount(gh<_i899.SyncRepository>()),
    );
    gh.lazySingleton<_i796.SyncPendingWords>(
      () => _i796.SyncPendingWords(gh<_i899.SyncRepository>()),
    );
    gh.lazySingleton<_i75.GetPendingCount>(
      () => _i75.GetPendingCount(gh<_i899.SyncRepository>()),
    );
    gh.factory<_i70.AuthCubit>(
      () => _i70.AuthCubit(
        gh<_i33.SignInWithEmail>(),
        gh<_i588.SignUpWithEmail>(),
        gh<_i472.SignOut>(),
        gh<_i994.WordRepository>(),
        gh<_i915.AdoptGuestWords>(),
      ),
    );
    gh.factory<_i557.SyncCubit>(
      () => _i557.SyncCubit(
        gh<_i613.WatchPendingCount>(),
        gh<_i796.SyncPendingWords>(),
        gh<_i862.ConnectivityMonitor>(),
      ),
    );
    gh.factory<_i996.WorkspaceCubit>(
      () => _i996.WorkspaceCubit(
        gh<_i69.ProcessScript>(),
        gh<_i455.SaveProcessedWords>(),
        gh<_i646.ToggleKnownWord>(),
      ),
    );
    gh.factory<_i7.LibraryCubit>(
      () => _i7.LibraryCubit(
        gh<_i226.WatchWords>(),
        gh<_i906.UpdateWord>(),
        gh<_i774.DeleteWord>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i913.RegisterModule {}
