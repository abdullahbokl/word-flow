import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wordflow/core/database/app_database.dart';

void main() {
  group('Database Migration v9 to v10', () {
    test('preserves words and migrates excluded_words to is_excluded',
        () async {
      // 1. Create a database at version 9 manually using sqlite3
      final rawDb = sqlite3.openInMemory()
        ..execute('PRAGMA user_version = 9')
        ..execute('''
        CREATE TABLE words (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL UNIQUE,
          meaning TEXT,
          description TEXT,
          is_known INTEGER NOT NULL DEFAULT 0,
          frequency INTEGER NOT NULL DEFAULT 0,
          updated_at INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          definitions TEXT,
          examples TEXT,
          translations TEXT,
          synonyms TEXT
        );
      ''')
        ..execute('''
        CREATE TABLE analyzed_texts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          total_words INTEGER NOT NULL,
          unique_words INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          known_words INTEGER NOT NULL DEFAULT 0,
          unknown_words INTEGER NOT NULL DEFAULT 0
        );
      ''')
        ..execute('''
        CREATE TABLE text_word_entries (
          text_id INTEGER NOT NULL,
          word_id INTEGER NOT NULL,
          local_frequency INTEGER NOT NULL DEFAULT 1,
          PRIMARY KEY (text_id, word_id),
          FOREIGN KEY (text_id) REFERENCES analyzed_texts (id) ON DELETE CASCADE,
          FOREIGN KEY (word_id) REFERENCES words (id) ON DELETE CASCADE
        );
      ''')
        ..execute('''
        CREATE TABLE excluded_words (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT UNIQUE NOT NULL,
          created_at INTEGER NOT NULL
        );
      ''');

      // 2. Insert some data at v9
      final now = DateTime.now().millisecondsSinceEpoch;
      rawDb
        ..execute(
          'INSERT INTO words (word, updated_at, created_at) VALUES (?, ?, ?)',
          ['active_word', now, now],
        )
        ..execute(
          'INSERT INTO words (word, updated_at, created_at) VALUES (?, ?, ?)',
          ['excluded_word_to_be', now, now],
        )
        ..execute(
          'INSERT INTO excluded_words (word, created_at) VALUES (?, ?)',
          ['excluded_word_to_be', now],
        );

      // 3. Open the database with the current code (v10)
      final executor = NativeDatabase.opened(rawDb);
      final dbV10 = AppDatabase.forTesting(e: executor);

      // Trigger migration by performing a query
      final allWords = await dbV10.select(dbV10.words).get();

      // 4. Verify data preservation and migration
      expect(allWords.length, 2);

      final activeWord = allWords.firstWhere((w) => w.word == 'active_word');
      expect(activeWord.isExcluded, isFalse);

      final excludedWord =
          allWords.firstWhere((w) => w.word == 'excluded_word_to_be');
      expect(excludedWord.isExcluded, isTrue);

      // 5. Verify new tables exist
      final tags = await dbV10.select(dbV10.customTags).get();
      expect(tags, isEmpty);

      // 6. Verify old table is dropped
      try {
        await dbV10.customSelect('SELECT * FROM excluded_words').get();
        fail('excluded_words table should have been dropped');
      } catch (e) {
        expect(e.toString(), contains('no such table: excluded_words'));
      }

      await dbV10.close();
    });
  });
}
