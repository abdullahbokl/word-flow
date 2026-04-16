import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:wordflow/core/database/converters/string_list_converter.dart';
import 'package:wordflow/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
    tables: [Words, AnalyzedTexts, TextWordEntries, CustomTags, WordCustomTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting({required QueryExecutor e}) : super(e);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(words, words.meaning);
          await m.addColumn(words, words.description);
        }
        if (from < 3) {
          await m.addColumn(analyzedTexts, analyzedTexts.knownWords);
          await m.addColumn(analyzedTexts, analyzedTexts.unknownWords);
        }
        if (from < 4) {
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_words_is_known_frequency ON words (is_known, frequency)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_words_updated_at ON words (updated_at)',
          );
        }
        if (from < 5) {
          await m.addColumn(words, words.definitions);
          await m.addColumn(words, words.examples);
          await m.addColumn(words, words.translations);
          await m.addColumn(words, words.synonyms);
        }
        if (from < 6) {
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_text_word_entries_text_id ON text_word_entries (text_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_text_word_entries_word_id ON text_word_entries (word_id)',
          );
        }
        if (from < 7) {
          // Optimized composite index for (Filter + Frequency Sort + Alphabetical fallback)
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_words_filter_sort_freq ON words (is_known, frequency DESC, word ASC)',
          );
          // Optimized composite index for (Filter + Recency Sort + Alphabetical fallback)
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_words_filter_sort_recent ON words (is_known, updated_at DESC, word ASC)',
          );
        }
        if (from < 8) {
          await customStatement(
              'CREATE TABLE IF NOT EXISTS excluded_words (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT UNIQUE NOT NULL, created_at INTEGER NOT NULL)');
        }
        if (from < 9) {
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_analyzed_texts_created_at ON analyzed_texts (created_at DESC)',
          );
        }
        if (from < 10) {
          // 1. Add new columns to words
          await m.addColumn(words, words.isExcluded);
          await m.addColumn(words, words.category);
          await m.addColumn(words, words.reviewSchedule);

          // 2. Create new tables
          await m.createTable(customTags);
          await m.createTable(wordCustomTags);

          // 3. Data migration: excluded_words -> words.is_excluded
          await customStatement(
            'UPDATE words SET is_excluded = 1 WHERE word IN (SELECT word FROM excluded_words)',
          );
          await customStatement(
            'UPDATE words SET is_excluded = 0 WHERE is_excluded IS NULL',
          );

          // 4. Drop old table
          await customStatement('DROP TABLE IF EXISTS excluded_words');

          // 5. Create indices
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_words_is_excluded ON words (is_excluded)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_words_category ON words (category)',
          );
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        // Ensure critical performance indices exist
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_words_filter_sort_freq ON words (is_known, frequency DESC, word ASC)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_words_filter_sort_recent ON words (is_known, updated_at DESC, word ASC)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_text_word_entries_text_id ON text_word_entries (text_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_text_word_entries_word_id ON text_word_entries (word_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_analyzed_texts_created_at ON analyzed_texts (created_at DESC)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_words_is_excluded ON words (is_excluded)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_words_category ON words (category)',
        );
      },
    );
  }

  Stream<List<WordRow>> watchActiveWords() {
    return (select(words)..where((t) => t.isExcluded.equals(false))).watch();
  }

  Future<void> checkpoint() async {
    await customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'lexitrack');
}
