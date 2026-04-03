import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Database connection test', () async {
    final db = WordFlowDatabase();
    final count = await db.countWords();
    expect(count, isNotNull);
  });
}
