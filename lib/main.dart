import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lexitrack/app/app.dart';
import 'package:lexitrack/app/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDI();
  runApp(const LexiTrackApp());
}
