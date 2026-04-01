import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import 'package:word_flow/app/app.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/core/config/env_config.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/security/security_service.dart';
import 'package:word_flow/core/security/supabase_secure_storage.dart';
import 'package:word_flow/core/connectivity/connectivity_lifecycle_manager.dart';
import 'package:word_flow/features/vocabulary/data/sync/sync_orchestrator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime font fetching to ensure offline-first typography
  // All fonts are now bundled as assets in assets/fonts/
  GoogleFonts.config.allowRuntimeFetching = false;

  // Validate environment configuration (throws in DEBUG mode if missing)
  EnvConfig.validate();

  await SentryFlutter.init(
    (options) {
      options.dsn = EnvConfig.sentryDsn;
      options.tracesSampleRate = kDebugMode ? 1.0 : 0.3;
      options.environment = kDebugMode ? 'development' : 'production';
      options.sendDefaultPii = false;
    },
    appRunner: () async {
      await configureDependencies();

      final logger = getIt<AppLogger>();

      // Configure BLoC logging based on build mode
      // DEBUG: Log all state transitions (info level) + errors
      // RELEASE: Only log BLoC errors (no state transition spam)
      // Verbose logging suppressed via AppLogger's kDebugMode checks
      Bloc.observer = TalkerBlocObserver(talker: logger.talker);

      // Attach Sentry breadcrumb behavior (verbose in debug, minimal in release)
      logger.attachToSentry();

      try {
        if (EnvConfig.isConfigured) {
          final securityService = getIt<SecurityService>();
          await Supabase.initialize(
            url: EnvConfig.supabaseUrl,
            anonKey: EnvConfig.supabaseAnonKey,
            authOptions: FlutterAuthClientOptions(
              localStorage: SupabaseSecureStorage(securityService),
            ),
          );
        } else {
          logger.warning(
            'Warning: Supabase credentials not found. Remote sync will be disabled.',
            category: LogCategory.network,
          );
        }
      } catch (e, stackTrace) {
        logger.error(
          'Supabase initialization failed',
          error: e,
          stackTrace: stackTrace,
          category: LogCategory.network,
        );
        // Report to Sentry as well
        await Sentry.captureException(e, stackTrace: stackTrace);
      }

      // Observe app lifecycle to auto-clean lazy singleton connectivity resources.
      getIt<ConnectivityLifecycleManager>().start();

      // Start global synchronization orchestration loop
      getIt<SyncOrchestrator>().start();

      runApp(const WordFlowApp());
    },
  );
}
