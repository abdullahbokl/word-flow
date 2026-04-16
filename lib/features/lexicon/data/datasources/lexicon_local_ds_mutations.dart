import 'dart:convert';
import 'package:drift/drift.dart';

import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/core/error/exceptions.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';

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
  bool? isExcluded,
  String? category,
  Map<String, dynamic>? reviewSchedule,
}) async {
  final now = DateTime.now();
  await (db.update(db.words)..where((row) => row.id.equals(id))).write(
    WordsCompanion(
      word: text != null
          ? Value(text.trim().toLowerCase())
          : const Value.absent(),
      meaning: meaning != null ? Value(meaning) : const Value.absent(),
      description:
          description != null ? Value(description) : const Value.absent(),
      definitions:
          definitions != null ? Value(definitions) : const Value.absent(),
      examples: examples != null ? Value(examples) : const Value.absent(),
      translations:
          translations != null ? Value(translations) : const Value.absent(),
      synonyms: synonyms != null ? Value(synonyms) : const Value.absent(),
      isKnown: isKnown != null ? Value(isKnown) : const Value.absent(),
      isExcluded: isExcluded != null ? Value(isExcluded) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      reviewSchedule: reviewSchedule != null
          ? Value(json.encode(reviewSchedule))
          : const Value.absent(),
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

Future<WordRow> restoreWordRow(
  AppDatabase db,
  String text,
  int previousId,
  int previousFrequency,
  bool wasFullyDeleted,
) async {
  if (wasFullyDeleted) {
    final now = DateTime.now();
    final id = await db.into(db.words).insert(
          WordsCompanion.insert(
            word: text.trim().toLowerCase(),
            frequency: const Value(1),
            isKnown: const Value(false),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    if (id == 0) {
      throw const DatabaseException('Word could not be restored');
    }
    return WordRow(
      id: id,
      word: text,
      frequency: 1,
      isKnown: false,
      isExcluded: false,
      createdAt: now,
      updatedAt: now,
    );
  } else {
    await (db.update(db.words)..where((row) => row.id.equals(previousId)))
        .write(
      WordsCompanion(
        frequency: Value(previousFrequency),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final row = await (db.select(db.words)
          ..where((row) => row.id.equals(previousId)))
        .getSingle();
    return row;
  }
}

Future<WordRow> addWordRow(AppDatabase db, String text,
    {bool isExcluded = false}) async {
  final now = DateTime.now();
  final id = await db.into(db.words).insert(
        WordsCompanion.insert(
          word: text.trim().toLowerCase(),
          frequency: const Value(0),
          isKnown: const Value(false),
          isExcluded: Value(isExcluded),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  if (id == 0) {
    // If word already exists, update its isExcluded status if requested
    final existing = await (db.select(db.words)
          ..where((row) => row.word.equals(text.trim().toLowerCase())))
        .getSingle();
    if (isExcluded && !existing.isExcluded) {
      await (db.update(db.words)
            ..where((row) => row.word.equals(text.trim().toLowerCase())))
          .write(WordsCompanion(
              isExcluded: const Value(true), updatedAt: Value(now)));
      return existing.copyWith(isExcluded: true, updatedAt: now);
    }
    return existing;
  }

  return WordRow(
    id: id,
    word: text,
    frequency: 0,
    isKnown: false,
    isExcluded: isExcluded,
    createdAt: now,
    updatedAt: now,
  );
}

Future<List<WordRow>> addMultipleWordsRow(AppDatabase db, List<String> words,
    {bool isExcluded = false}) async {
  final now = DateTime.now();
  final results = <WordRow>[];

  await db.batch((batch) {
    for (final text in words) {
      batch.insert(
        db.words,
        WordsCompanion.insert(
          word: text.trim().toLowerCase(),
          frequency: const Value(0),
          isKnown: const Value(false),
          isExcluded: Value(isExcluded),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  });

  // Fetch all inserted/existing words to return them
  for (final text in words) {
    final row = await (db.select(db.words)
          ..where((row) => row.word.equals(text.trim().toLowerCase())))
        .getSingle();
    results.add(row);
  }

  return results;
}

Future<LexiconStats> getLexiconStats(AppDatabase db) async {
  final res = await db
      .customSelect(
          'SELECT COUNT(*) as total, SUM(CASE WHEN is_known = 1 AND is_excluded = 0 THEN 1 ELSE 0 END) as known, SUM(CASE WHEN is_excluded = 1 THEN 1 ELSE 0 END) as excluded FROM words')
      .getSingle();
  final totalCount = res.read<int>('total');
  final known = res.read<int?>('known') ?? 0;
  final excluded = res.read<int?>('excluded') ?? 0;
  final lexiconTotal = totalCount - excluded;
  return LexiconStats(
    total: lexiconTotal,
    known: known,
    unknown: lexiconTotal - known,
    excluded: excluded,
  );
}

Stream<LexiconStats> watchLexiconStats(AppDatabase db) {
  return db
      .customSelect(
        'SELECT COUNT(*) as total, SUM(CASE WHEN is_known = 1 AND is_excluded = 0 THEN 1 ELSE 0 END) as known, SUM(CASE WHEN is_excluded = 1 THEN 1 ELSE 0 END) as excluded FROM words',
        readsFrom: {db.words},
      )
      .watchSingle()
      .map((res) {
        final totalCount = res.read<int>('total');
        final known = res.read<int?>('known') ?? 0;
        final excluded = res.read<int?>('excluded') ?? 0;
        final lexiconTotal = totalCount - excluded;
        return LexiconStats(
          total: lexiconTotal,
          known: known,
          unknown: lexiconTotal - known,
          excluded: excluded,
        );
      });
}
