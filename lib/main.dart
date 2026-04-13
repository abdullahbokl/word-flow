import 'package:flutter/material.dart';
import 'package:wordflow/app/app.dart';
import 'package:wordflow/app/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDI();
  runApp(const WordFlowApp());
}
