import 'package:flutter_test/flutter_test.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/data/datasources/category_local_ds_impl.dart';

import '../../../helpers/mock_database.dart';

void main() {
  late CategoryLocalDataSourceImpl dataSource;
  late AppDatabase db;

  setUp(() {
    db = getMockDatabase();
    dataSource = CategoryLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Category Management', () {
    test('addCustomTag adds a tag and getCustomTags retrieves it', () async {
      final tag = await dataSource.addCustomTag('Test Tag');
      expect(tag.name, 'Test Tag');

      final tags = await dataSource.getCustomTags();
      expect(tags.length, 1);
      expect(tags.first.name, 'Test Tag');
    });

    test('deleteCustomTag removes a tag', () async {
      final tag = await dataSource.addCustomTag('To Delete');
      await dataSource.deleteCustomTag(tag.id);

      final tags = await dataSource.getCustomTags();
      expect(tags, isEmpty);
    });

    test('assignTag and getWordTags works correctly', () async {
      // Add a word first
      final wordId = await db.into(db.words).insert(WordsCompanion.insert(
            word: 'test',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));

      final tag = await dataSource.addCustomTag('Tag 1');
      await dataSource.assignTag(wordId, tag.id);

      final wordTags = await dataSource.getWordTags(wordId);
      expect(wordTags.length, 1);
      expect(wordTags.first.name, 'Tag 1');
    });

    test('removeTag removes the association', () async {
      final wordId = await db.into(db.words).insert(WordsCompanion.insert(
            word: 'test',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));

      final tag = await dataSource.addCustomTag('Tag 1');
      await dataSource.assignTag(wordId, tag.id);
      await dataSource.removeTag(wordId, tag.id);

      final wordTags = await dataSource.getWordTags(wordId);
      expect(wordTags, isEmpty);
    });

    test('watchCustomTags reflects changes', () async {
      final stream = dataSource.watchCustomTags();

      final expectation = expectLater(
          stream,
          emitsInOrder([
            isEmpty,
            predicate((tags) => (tags as List).length == 1),
          ]));

      await Future.delayed(const Duration(milliseconds: 100));
      await dataSource.addCustomTag('New Tag');
      await expectation;
    });
  });
}
