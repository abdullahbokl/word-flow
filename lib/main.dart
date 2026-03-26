import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'app/di.dart';
import 'core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Only initialize if we have credentials
    if (EnvConfig.isConfigured) {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
    } else {
      debugPrint('Warning: Supabase credentials not found. Remote sync will be disabled.');
      // Special flag for dev with missing credentials might be needed
    }
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  // Initialize DI
  configureDependencies();
  
  runApp(const WordFlowApp());
}
