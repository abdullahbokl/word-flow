import 'package:drift/drift.dart';
import 'package:wordflow/core/database/app_database.dart';

Future<void> updateAnalyzedTextCounts(AppDatabase db, int analysisId) async {
  final entries = await (db.select(db.textWordEntries).join([
    innerJoin(db.words, db.words.id.equalsExp(db.textWordEntries.wordId)),
  ])
        ..where(db.textWordEntries.textId.equals(analysisId)))
      .get();

  final knownCount = entries.where((r) => r.readTable(db.words).isKnown).length;
  final uniqueCount = entries.length;

  await (db.update(db.analyzedTexts)..where((t) => t.id.equals(analysisId)))
      .write(
    AnalyzedTextsCompanion(
      knownWords: Value(knownCount),
      unknownWords: Value(uniqueCount - knownCount),
    ),
  );
}
