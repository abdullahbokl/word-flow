import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/core/config/env_config.dart';
import 'package:word_flow/core/errors/exceptions.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/utils/rate_limiter.dart';
import 'package:word_flow/core/utils/rate_limiter_storage.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/data/datasources/auth_remote_source.dart';
import 'package:word_flow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:word_flow/features/auth/data/repositories/guest_auth_repository.dart';
import 'package:word_flow/core/di/injection.config.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/database/database_key_manager.dart';

import 'package:word_flow/features/vocabulary/data/datasources/word_remote_source.dart';

final getIt = GetIt.instance;
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

const String _secureStorageUnavailableMessage =
    'Secure storage unavailable. Your data cannot be protected. Please restart the app or contact support.';

void _scheduleSecureStorageUnavailableDialog() {
  const maxAttempts = 20;
  var attempts = 0;

  Future<void> tryShowDialog() async {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Secure Storage Error'),
          content: const Text(_secureStorageUnavailableMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    attempts++;
    if (attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      await tryShowDialog();
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(tryShowDialog());
  });
}

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
  @Named('auth_rate_limiter')
  RateLimiter authRateLimiter(RateLimiterStorage storage) {
    return RateLimiter(storage: storage, storageKey: 'auth');
  }

  @lazySingleton
  @Named('migration_rate_limiter')
  RateLimiter migrationRateLimiter(RateLimiterStorage storage) {
    return RateLimiter(storage: storage, storageKey: 'migration');
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
      return AuthRepositoryImpl(
        supabaseClient,
        getIt<AuthRemoteSource>(),
        getIt<AppLogger>(),
      );
    }
    return GuestAuthRepository();
  }

  @lazySingleton
  @Named('secure_storage')
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  @lazySingleton
  @preResolve
  Future<WordFlowDatabase> getDatabase(DatabaseKeyManager keyManager) async {
    try {
      final key = await keyManager.getOrCreateKey();
      return WordFlowDatabase(key);
    } on KeyPersistenceException catch (error, stackTrace) {
      final logger = getIt.isRegistered<AppLogger>()
          ? getIt<AppLogger>()
          : AppLogger();

      logger.error(
        'Database initialization failed due to secure storage persistence error',
        error,
        stackTrace,
      );
      await Sentry.captureException(error, stackTrace: stackTrace);
      _scheduleSecureStorageUnavailableDialog();
      rethrow;
    }
  }
}

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => await getIt.init();
