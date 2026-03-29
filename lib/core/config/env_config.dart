class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Sentry DSN (set via --dart-define=SENTRY_DSN=...)
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static void validate() {
    if (!isConfigured) {
      throw Exception(
        'Supabase configuration missing. '
        'Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
      );
    }
  }
}
