/// Main entry point for the LexiTrack application.
library;

import 'package:flutter/material.dart';

import 'package:lexitrack/app/app.dart';
import 'package:lexitrack/app/di/injection.dart';

/// Initializes the application services and runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDI();

  runApp(const LexiTrackApp());
}
