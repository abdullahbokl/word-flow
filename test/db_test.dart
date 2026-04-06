import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:word_flow/core/database/app_database.dart';

void main() {
  test('Database connection test', () async {
    final db = WordFlowDatabase(NativeDatabase.memory());
    final count = await db.countWords();
    expect(count, isNotNull);
  });
}
