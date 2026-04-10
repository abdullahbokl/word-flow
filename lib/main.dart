import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lexitrack/app/app.dart';
import 'package:lexitrack/app/di/injection.dart';
import 'package:sqlite3/open.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    open.overrideFor(OperatingSystem.android, () {
      return DynamicLibrary.open('libsqlite3.so');
    });
  }

  await initDI();
  runApp(const LexiTrackApp());
}
