import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Words, AnalyzedTexts, TextWordEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 3;

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
          // Drift automatically handles foreign keys in createAll()
          // For a live app with data, we might need a more complex migration to add FKs to existing tables
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
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
