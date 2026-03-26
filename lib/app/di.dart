import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'di.config.dart';

final getIt = GetIt.instance;

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient {
    try {
      return Supabase.instance.client;
    } catch (e) {
      // In tests or if not initialized, we shouldn't crash here.
      // But for production, this should only happen if main() failed to initialize.
      // We return a "dummy" or throw a more informative error.
      throw Exception('SupabaseClient requested but Supabase is NOT initialized. '
          'Ensure Supabase.initialize is called in main(). Error: $e');
    }
  }
}

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();
