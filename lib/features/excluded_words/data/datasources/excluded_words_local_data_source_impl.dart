import 'package:drift/drift.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/excluded_words/data/datasources/excluded_words_local_data_source.dart';

class ExcludedWordsLocalDataSourceImpl implements ExcludedWordsLocalDataSource {
  final AppDatabase _db;

  ExcludedWordsLocalDataSourceImpl(this._db);

  @override
  Future<List<ExcludedWordRow>> getExcludedWords() async {
    return _db.select(_db.excludedWords).get();
  }

  @override
  Future<ExcludedWordRow> addExcludedWord(String word) async {
    final normalizedWord = word.toLowerCase().trim();

    // Check if word already exists to avoid UNIQUE constraint failure
    final existing = await (_db.select(_db.excludedWords)
          ..where((t) => t.word.equals(normalizedWord)))
        .getSingleOrNull();

    if (existing != null) {
      return existing;
    }

    return _db.into(_db.excludedWords).insertReturning(
          ExcludedWordsCompanion.insert(
            word: normalizedWord,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<ExcludedWordRow> updateExcludedWord(ExcludedWordRow word) async {
    await _db.update(_db.excludedWords).replace(word);
    return word;
  }

  @override
  Future<void> deleteExcludedWord(int id) async {
    await (_db.delete(_db.excludedWords)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<ExcludedWordRow>> addMultipleExcludedWords(
      List<String> words) async {
    final now = DateTime.now();
    await _db.batch((batch) {
      for (final word in words) {
        batch.insert(
          _db.excludedWords,
          ExcludedWordsCompanion.insert(
            word: word.toLowerCase().trim(),
            createdAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
    return getExcludedWords();
  }
}
