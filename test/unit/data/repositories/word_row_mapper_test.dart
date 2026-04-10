import 'package:flutter_test/flutter_test.dart';
import 'package:lexitrack/core/data/mappers/word_row_mapper.dart';
import 'package:lexitrack/core/database/app_database.dart';

void main() {
  group('WordRowMapper.toEntity', () {
    test('maps all fields correctly', () {
      final now = DateTime(2024);
      final row = WordRow(
        id: 42,
        word: 'flutter',
        frequency: 10,
        isKnown: true,
        createdAt: now,
        updatedAt: now,
        meaning: 'A software framework',
        description: 'Used for cross-platform apps',
      );

      final entity = row.toEntity();

      expect(entity.id, 42);
      expect(entity.text, 'flutter');
      expect(entity.frequency, 10);
      expect(entity.isKnown, true);
      expect(entity.createdAt, now);
      expect(entity.updatedAt, now);
      expect(entity.meaning, 'A software framework');
      expect(entity.description, 'Used for cross-platform apps');
    });

    test('handles null meaning and description', () {
      final now = DateTime(2024);
      final row = WordRow(
        id: 1,
        word: 'test',
        frequency: 1,
        isKnown: false,
        createdAt: now,
        updatedAt: now,
      );

      final entity = row.toEntity();

      expect(entity.meaning, isNull);
      expect(entity.description, isNull);
    });
  });
}
