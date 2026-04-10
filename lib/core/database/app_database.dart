import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'converters/string_list_converter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Words, AnalyzedTexts, TextWordEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting({required QueryExecutor e}) : super(e);

  @override
  int get schemaVersion => 5;

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
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_words_is_known_frequency ON words (is_known, frequency)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_words_updated_at ON words (updated_at)',
        );
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lexitrack.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
