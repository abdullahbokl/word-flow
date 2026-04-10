import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/lexicon_stats.dart';

Future<WordRow> toggleWordStatus(AppDatabase db, int wordId) async {
  final word = await (db.select(db.words)
        ..where((row) => row.id.equals(wordId)))
      .getSingleOrNull();

  if (word == null) {
    throw const DatabaseException('Word not found');
  }

  final now = DateTime.now();
  await (db.update(db.words)..where((row) => row.id.equals(wordId))).write(
    WordsCompanion(
      isKnown: Value(!word.isKnown),
      updatedAt: Value(now),
    ),
  );

  return word.copyWith(isKnown: !word.isKnown, updatedAt: now);
}

Future<WordRow> updateWordRow(
  AppDatabase db,
  int id, {
  String? text,
  String? meaning,
  String? description,
  List<String>? definitions,
  List<String>? examples,
  List<String>? translations,
  List<String>? synonyms,
  bool? isKnown,
}) async {
  final now = DateTime.now();
  await (db.update(db.words)..where((row) => row.id.equals(id))).write(
    WordsCompanion(
      word: text != null ? Value(text) : const Value.absent(),
      meaning: meaning != null ? Value(meaning) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      definitions: definitions != null ? Value(definitions) : const Value.absent(),
      examples: examples != null ? Value(examples) : const Value.absent(),
      translations: translations != null ? Value(translations) : const Value.absent(),
      synonyms: synonyms != null ? Value(synonyms) : const Value.absent(),
      isKnown: isKnown != null ? Value(isKnown) : const Value.absent(),
      updatedAt: Value(now),
    ),
  );

  return (db.select(db.words)..where((row) => row.id.equals(id))).getSingle();
}

Future<void> deleteWordRow(AppDatabase db, int wordId) async {
  final word = await (db.select(db.words)
        ..where((row) => row.id.equals(wordId)))
      .getSingleOrNull();

  if (word == null) return;

  if (word.frequency > 1) {
    await (db.update(db.words)..where((row) => row.id.equals(wordId))).write(
      WordsCompanion(
        frequency: Value(word.frequency - 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return;
  }

  await (db.delete(db.textWordEntries)
        ..where((entry) => entry.wordId.equals(wordId)))
      .go();
  await (db.delete(db.words)..where((row) => row.id.equals(wordId))).go();
}

Future<WordRow> addWordRow(AppDatabase db, String text) async {
  final now = DateTime.now();
  final id = await db.into(db.words).insert(
        WordsCompanion.insert(
          word: text,
          frequency: const Value(0),
          isKnown: const Value(false),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  if (id == 0) {
    throw const DatabaseException('Word already exists');
  }

  return WordRow(
    id: id,
    word: text,
    frequency: 0,
    isKnown: false,
    createdAt: now,
    updatedAt: now,
  );
}

Future<LexiconStats> getLexiconStats(AppDatabase db) async {
  final res = await db
      .customSelect(
          'SELECT COUNT(*) as total, SUM(CASE WHEN is_known = 1 THEN 1 ELSE 0 END) as known FROM words')
      .getSingle();
  final total = res.read<int>('total');
  final known = res.read<int?>('known') ?? 0;
  return LexiconStats(total: total, known: known, unknown: total - known);
}

Stream<LexiconStats> watchLexiconStats(AppDatabase db) {
  return db
      .customSelect(
          'SELECT COUNT(*) as total, SUM(CASE WHEN is_known = 1 THEN 1 ELSE 0 END) as known FROM words')
      .watchSingle()
      .map((res) {
    final total = res.read<int>('total');
    final known = res.read<int?>('known') ?? 0;
    return LexiconStats(total: total, known: known, unknown: total - known);
  });
}
