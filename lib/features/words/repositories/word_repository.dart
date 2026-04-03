import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/words/models/word.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class WordRepository {
  WordRepository(this._db);
  final WordFlowDatabase _db;

  Future<Either<Failure, List<Word>>> getWords({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    bool? isKnown,
  }) async {
    try {
      final rows = await _db.getWordsPaginated(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
        isKnown: isKnown,
      );
      return Right(rows.map(_mapRowToWord).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> countWords({
    String? searchQuery,
    bool? isKnown,
  }) async {
    try {
      final count = await _db.countWords(
        searchQuery: searchQuery,
        isKnown: isKnown,
      );
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> upsertWord(Word word) async {
    try {
      await _db.upsertWord(
        WordsCompanion.insert(
          id: word.id,
          wordText: word.wordText,
          totalCount: Value(word.totalCount),
          isKnown: Value(word.isKnown),
          lastUpdated: word.lastUpdated,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteWord(String id) async {
    try {
      await _db.deleteWordById(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> toggleKnown(String wordText) async {
    try {
      final existing = await _db.getWordByText(wordText);
      if (existing != null) {
        await _db.upsertWord(
          WordsCompanion(
            id: Value(existing.id),
            wordText: Value(existing.wordText),
            isKnown: Value(!existing.isKnown),
            lastUpdated: Value(DateTime.now().toUtc()),
          ),
        );
      } else {
        await _db.upsertWord(
          WordsCompanion.insert(
            id: const Uuid().v4(),
            wordText: wordText,
            isKnown: const Value(true),
            lastUpdated: DateTime.now().toUtc(),
          ),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<String>>> getKnownWordTexts() async {
    try {
      final texts = await _db.getKnownWordTexts();
      return Right(texts);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Word _mapRowToWord(WordRow row) {
    return Word(
      id: row.id,
      wordText: row.wordText,
      totalCount: row.totalCount,
      isKnown: row.isKnown,
      lastUpdated: row.lastUpdated,
    );
  }
}
