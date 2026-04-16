import 'package:flutter_test/flutter_test.dart';
import '../../helpers/mock_database.dart';

void main() {
  group('Database Migration', () {
    test('initializes database successfully', () async {
      final db = getMockDatabase();

      // Simple query to ensure DB is open and schema is applied
      final words = await db.select(db.words).get();
      expect(words, isEmpty);

      await db.close();
    });
  });
}
