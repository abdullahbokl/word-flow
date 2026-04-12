import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:lexitrack/core/database/converters/string_list_converter.dart';
import 'package:lexitrack/core/database/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Words, AnalyzedTexts, TextWordEntries, ExcludedWords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting({required QueryExecutor e}) : super(e);

  @override
  int get schemaVersion => 8;

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
      },
    );
  }

  Future<void> checkpoint() async {
    await customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lexitrack.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
