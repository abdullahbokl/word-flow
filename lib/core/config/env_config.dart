import 'package:flutter/foundation.dart';
import 'package:word_flow/core/logging/app_logger.dart';

/// Environment configuration for WordFlow.
///
/// **Configuration via dart-define:**
/// - SUPABASE_URL: Your Supabase project URL (required)
/// - SUPABASE_ANON_KEY: Your Supabase anonymous key (required)
/// - SENTRY_DSN: Sentry error reporting DSN (optional)
///
/// **Setup Instructions:**
/// 1. Copy `dart_define.json.example` to `dart_define.json` (local only, not committed)
/// 2. Update `dart_define.json` with your credentials
/// 3. Use `make run` or `flutter run --dart-define-from-file=dart_define.json`
///
/// **Validation Behavior:**
/// - **DEBUG mode**: Throws exception if required vars are missing.
/// - **RELEASE mode**: Logs warning, never crashes (graceful degradation).
class EnvConfig {
  // Private constructor — static-only access
  EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String sentryDsn =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  /// Check if Supabase is configured.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Check if Sentry is configured.
  static bool get isSentryConfigured => sentryDsn.isNotEmpty;

  /// Validate environment configuration.
  ///
  /// **DEBUG mode:**
  /// - Throws [StateError] if required vars are missing.
  /// - Ensures developers catch config issues early.
  ///
  /// **RELEASE mode:**
  /// - Logs warning if config is missing.
  /// - Never throws (graceful degradation).
  /// - App continues in offline-only mode.
  static void validate() {
    if (kDebugMode) {
      _validateDebugMode();
    } else {
      _validateReleaseMode();
    }
  }

  static void _validateDebugMode() {
    final missing = <String>[];

    if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');

    if (missing.isNotEmpty) {
      throw StateError(
        '''
╔════════════════════════════════════════════════════════════════╗
║              ENVIRONMENT CONFIGURATION ERROR                   ║
╚════════════════════════════════════════════════════════════════╝

Missing required dart-define variables: ${missing.join(', ')}

**Setup Instructions:**
1. Copy dart_define.json.example → dart_define.json
2. Update dart_define.json with your Supabase credentials
3. Run: make run  (or flutter run --dart-define-from-file=dart_define.json)

**Troubleshooting:**
- Ensure dart_define.json exists in project root
- Check that SUPABASE_URL and SUPABASE_ANON_KEY are not empty
- For CI/CD: Use GitHub Actions secrets via --dart-define

**Reference:** docs/environment-setup.md
        ''',
      );
    }
  }

  static void _validateReleaseMode() {
    final logger = AppLogger();

    if (!isConfigured) {
      logger.warning(
        '⚠️  Supabase configuration not found. '
        'Remote sync is disabled. App will work in offline-only mode.',
      );
    }

    if (!isSentryConfigured) {
      logger.info(
        'ℹ️  Sentry DSN not configured. Error reporting is disabled.',
      );
    }
  }

  /// Get human-readable config status (for logging/debugging).
  static String getConfigStatus() {
    final buffer = StringBuffer();
    buffer.writeln('Environment Configuration:');
    buffer.writeln('- Supabase: ${isConfigured ? '✅ Configured' : '❌ Missing'}');
    buffer.writeln('- Sentry: ${isSentryConfigured ? '✅ Configured' : '⚠️  Optional'}');
    buffer.writeln('- Debug Mode: ${kDebugMode ? '🔧️ ON' : '🔒 OFF'}');
    return buffer.toString();
  }
}

