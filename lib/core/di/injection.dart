import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/core/di/injection.config.dart';

final getIt = GetIt.instance;

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient {
    try {
      return Supabase.instance.client;
    } catch (e) {
     
     
     
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
