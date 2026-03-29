import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/app/app.dart';
import 'package:word_flow/app/di.dart';
import 'package:word_flow/core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (EnvConfig.isConfigured) {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
    } else {
      debugPrint(
        'Warning: Supabase credentials not found. Remote sync will be disabled.',
      );
    }
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  configureDependencies();

  runApp(const WordFlowApp());
}
