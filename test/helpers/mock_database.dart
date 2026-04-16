import 'package:drift/native.dart';
import 'package:wordflow/core/database/app_database.dart';

/// Provides a memory-based [AppDatabase] for testing.
AppDatabase getMockDatabase() {
  return AppDatabase.forTesting(
    e: NativeDatabase.memory(),
  );
}
