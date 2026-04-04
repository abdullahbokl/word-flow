import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDI();

  runApp(const LexiTrackApp());
}
