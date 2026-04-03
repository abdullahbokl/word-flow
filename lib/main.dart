import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:word_flow/app/app.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/core/logging/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime font fetching to ensure offline-first typography
  GoogleFonts.config.allowRuntimeFetching = false;

  await configureDependencies();

  final logger = getIt<AppLogger>();
  logger.info('WordFlow started in local-only mode');

  runApp(const WordFlowApp());
}
