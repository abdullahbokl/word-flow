import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/core/config/env_config.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:word_flow/features/auth/data/repositories/guest_auth_repository.dart';
import 'package:word_flow/core/di/injection.config.dart';

final getIt = GetIt.instance;

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient {
    if (!EnvConfig.isConfigured) {
      // Provide a dummy client to avoid DI crashes when keys are missing.
      return SupabaseClient('https://disabled.supabase.io', 'disabled');
    }
    return Supabase.instance.client;
  }

  @lazySingleton
  AuthRepository get authRepository {
    if (EnvConfig.isConfigured) {
      return AuthRepositoryImpl(supabaseClient);
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
}

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();
