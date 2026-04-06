import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../lib/core/common/mappers/word_row_mapper.dart';
import '../../../lib/core/database/app_database.dart';

class MockWordRow extends Mock implements WordRow {
  @override
  int get id => 42;
  @override
  String get word => 'flutter';
  @override
  int get frequency => 10;
  @override
  bool get isKnown => true;
  @override
  DateTime get createdAt => DateTime(2024);
  @override
  DateTime get updatedAt => DateTime(2025);
  @override
  String? get meaning => 'A software framework';
  @override
  String? get description => 'Used for cross-platform apps';
}

// Note: extension method tests need a concrete implementation
void main() {
  group('WordRowMapper.toEntity', () {
    test('maps all fields correctly', () {
      final row = MockWordRow();

      final entity = row.toEntity();

      expect(entity.id, 42);
      expect(entity.text, 'flutter');
      expect(entity.frequency, 10);
      expect(entity.isKnown, true);
      expect(entity.createdAt, DateTime(2024));
      expect(entity.updatedAt, DateTime(2025));
      expect(entity.meaning, 'A software framework');
      expect(entity.description, 'Used for cross-platform apps');
    });
  });
}
