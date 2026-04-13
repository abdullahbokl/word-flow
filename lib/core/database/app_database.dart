import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:lexitrack/core/database/converters/string_list_converter.dart';
import 'package:lexitrack/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Words, AnalyzedTexts, TextWordEntries, ExcludedWords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting({required QueryExecutor e}) : super(e);

  @override
  int get schemaVersion => 9;

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
          await m.createTable(excludedWords);
        }
        if (from < 9) {
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_analyzed_texts_created_at ON analyzed_texts (created_at DESC)',
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
      },
    );
  }

  Future<void> checkpoint() async {
    await customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'lexitrack');
}
