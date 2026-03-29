import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import 'package:word_flow/app/app.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/core/config/env_config.dart';
import 'package:word_flow/core/logging/app_logger.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = EnvConfig.sentryDsn;
      options.tracesSampleRate = kDebugMode ? 1.0 : 0.3;
      options.environment = kDebugMode ? 'development' : 'production';
      options.sendDefaultPii = false;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      configureDependencies();

      final logger = getIt<AppLogger>();
      Bloc.observer = TalkerBlocObserver(talker: logger.talker);

      try {
        if (EnvConfig.isConfigured) {
          await Supabase.initialize(
            url: EnvConfig.supabaseUrl,
            anonKey: EnvConfig.supabaseAnonKey,
          );
        } else {
          logger.warning(
            'Warning: Supabase credentials not found. Remote sync will be disabled.',
          );
        }
      } catch (e, stackTrace) {
        logger.error('Supabase initialization failed', e, stackTrace);
        // Report to Sentry as well
        await Sentry.captureException(e, stackTrace: stackTrace);
      }

      runApp(const WordFlowApp());
    },
  );
}
