import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/core/config/env_config.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/data/datasources/auth_remote_source.dart';
import 'package:word_flow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:word_flow/features/auth/data/repositories/guest_auth_repository.dart';
import 'package:word_flow/core/di/injection.config.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/database/database_key_manager.dart';

import 'package:word_flow/features/vocabulary/data/datasources/word_remote_source.dart';

final getIt = GetIt.instance;

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient {
    if (!EnvConfig.isConfigured) {
      throw StateError('Supabase is not configured');
    }
    return Supabase.instance.client;
  }

  @lazySingleton
  WordRemoteSource get wordRemoteSource {
    if (EnvConfig.isConfigured) {
      return WordRemoteSourceImpl(supabaseClient);
    }
    return DisabledWordRemoteSource();
  }

  @lazySingleton
  AuthRepository get authRepository {
    if (EnvConfig.isConfigured) {
      return AuthRepositoryImpl(supabaseClient, getIt<AuthRemoteSource>(), getIt<AppLogger>());
    }
    return GuestAuthRepository();
  }

  @lazySingleton
  @Named('secure_storage')
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );
  @lazySingleton
  @preResolve
  Future<WordFlowDatabase> getDatabase(DatabaseKeyManager keyManager) async {
    final key = await keyManager.getOrCreateKey();
    return WordFlowDatabase(key);
  }
}

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => await getIt.init();
