import 'dart:async';
import 'dart:io';

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
import 'package:word_flow/core/widgets/database_recovery_dialog.dart';

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

Future<void> resetAppData(WordFlowDatabase database) async {
  final logger = getIt.isRegistered<AppLogger>()
      ? getIt<AppLogger>()
      : AppLogger();
  final secureStorage = getIt<FlutterSecureStorage>(
    instanceName: 'secure_storage',
  );
  final keyManager = getIt<DatabaseKeyManager>();

  final databasePath = await database.getDatabaseFilePath();
  try {
    await database.close();
  } catch (error, stackTrace) {
    logger.error(
      'Failed to close database during reset',
      error: error,
      stackTrace: stackTrace,
      category: LogCategory.database,
    );
  }

  if (databasePath != null) {
    try {
      final file = File(databasePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error, stackTrace) {
      logger.error(
        'Failed deleting database file during reset',
        error: error,
        stackTrace: stackTrace,
        category: LogCategory.database,
      );
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  try {
    await secureStorage.deleteAll();
    await keyManager.getOrCreateKey();
  } catch (error, stackTrace) {
    logger.error(
      'Failed regenerating secure storage key during reset',
      error: error,
      stackTrace: stackTrace,
      category: LogCategory.app,
    );
    await Sentry.captureException(error, stackTrace: stackTrace);
  }
}

void _scheduleDatabaseRecoveryDialog(WordFlowDatabase database) {
  const maxAttempts = 20;
  var attempts = 0;

  Future<void> tryShowDialog() async {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => DatabaseRecoveryDialog(
          onTryAgain: () async {
            final keyOk = await database.verifyEncryptionKey();
            final integrityOk = keyOk
                ? await database.verifyIntegrity()
                : false;

            if (dialogContext.mounted && keyOk && integrityOk) {
              Navigator.of(dialogContext).pop();
              return;
            }

            if (dialogContext.mounted) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text('Database verification still failing.'),
                ),
              );
            }
          },
          onResetAppData: () async {
            await resetAppData(database);
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text(
                    'App data reset complete. Restart the app to continue.',
                  ),
                ),
              );
            }
          },
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
  RateLimiter authRateLimiter(RateLimiterStorage storage, AppLogger logger) {
    return RateLimiter(storage: storage, storageKey: 'auth', logger: logger);
  }

  @lazySingleton
  @Named('migration_rate_limiter')
  RateLimiter migrationRateLimiter(
    RateLimiterStorage storage,
    AppLogger logger,
  ) {
    return RateLimiter(
      storage: storage,
      storageKey: 'migration',
      logger: logger,
    );
  }

  @lazySingleton
  WordRemoteSource wordRemoteSource(AppLogger logger) {
    if (EnvConfig.isConfigured) {
      return WordRemoteSourceImpl(supabaseClient, logger);
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
      final database = WordFlowDatabase(key);
      final keyValid = await database.verifyEncryptionKey();
      final integrityValid = keyValid
          ? await database.verifyIntegrity()
          : false;

      if (!keyValid || !integrityValid) {
        const message =
            'Database startup verification failed (encryption key mismatch or integrity check failure).';
        final exception = StateError(message);
        final stackTrace = StackTrace.current;
        final logger = getIt.isRegistered<AppLogger>()
            ? getIt<AppLogger>()
            : AppLogger();
        logger.error(
          message,
          error: exception,
          stackTrace: stackTrace,
          category: LogCategory.database,
        );
        await Sentry.captureException(exception, stackTrace: stackTrace);
        _scheduleDatabaseRecoveryDialog(database);
      }

      return database;
    } on KeyPersistenceException catch (error, stackTrace) {
      final logger = getIt.isRegistered<AppLogger>()
          ? getIt<AppLogger>()
          : AppLogger();

      logger.error(
        'Database initialization failed due to secure storage persistence error',
        error: error,
        stackTrace: stackTrace,
        category: LogCategory.database,
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
