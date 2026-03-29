import 'package:injectable/injectable.dart';
import 'package:word_flow/features/words/data/models/word_model.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:drift/drift.dart' show Value;

abstract class WordLocalSource {
  Future<void> saveWord(WordModel word);
  Future<void> saveWords(List<WordModel> words);
  Future<Map<String, WordModel>> getWordTextMap({String? userId});
  Future<List<WordModel>> getWords({String? userId});
  Future<List<String>> getKnownWordTexts({String? userId});
  Future<WordModel?> getWordById(String id);
  Future<WordModel?> getWordByText(String text, {String? userId});
  Future<void> deleteWord(String id);
  Stream<List<WordModel>> watchWords({String? userId});
  Future<int> adoptGuestWords(String userId);
  Future<void> clearLocalWords({String? userId});
  Future<int> getGuestWordsCount();
}

@LazySingleton(as: WordLocalSource)
class WordLocalSourceImpl implements WordLocalSource {

  WordLocalSourceImpl(this._db);
  final WordFlowDatabase _db;

  @override
  Future<void> saveWord(WordModel word) async {
    await _db.upsertWord(_toCompanion(word));
  }

  @override
  Future<void> saveWords(List<WordModel> words) async {
    await _db.upsertWords(words.map(_toCompanion).toList(growable: false));
  }

  @override
  Future<Map<String, WordModel>> getWordTextMap({String? userId}) async {
    final query = _db.select(_db.words);
    if (userId != null) {
      query.where((t) => t.userId.equals(userId));
    } else {
      query.where((t) => t.userId.isNull());
    }
    final rows = await query.get();
    return {for (final row in rows) row.wordText: _fromRow(row)};
  }

  @override
  Future<int> getGuestWordsCount() async {
    return _db.getGuestWordsCount();
  }

  @override
  Future<List<WordModel>> getWords({String? userId}) async {
    final rows = await _db.watchWords(userId: userId).first;
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<List<String>> getKnownWordTexts({String? userId}) async {
    return _db.getKnownWordTexts(userId: userId);
  }

  @override
  Future<WordModel?> getWordById(String id) async {
    final row = await _db.getWordById(id);
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<WordModel?> getWordByText(String text, {String? userId}) async {
    final row = await _db.getWordByText(text, userId: userId);
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> deleteWord(String id) async {
    await _db.deleteWordById(id);
  }

  @override
  Stream<List<WordModel>> watchWords({String? userId}) async* {
    yield* _db.watchWords(userId: userId).map(
          (rows) => rows.map(_fromRow).toList(growable: false),
        );
  }

  @override
  Future<int> adoptGuestWords(String userId) async {
    return _db.adoptGuestWords(userId);
  }

  @override
  Future<void> clearLocalWords({String? userId}) async {
    await _db.clearLocalWords(userId: userId);
  }

  WordsCompanion _toCompanion(WordModel word) {
    return WordsCompanion.insert(
      id: word.id,
      userId: Value(word.userId),
      wordText: word.wordText,
      totalCount: Value(word.totalCount),
      isKnown: Value(word.isKnown),
      lastUpdated: word.lastUpdated.toUtc(),
    );
  }

  WordModel _fromRow(WordRow row) {
    return WordModel(
      id: row.id,
      userId: row.userId,
      wordText: row.wordText,
      totalCount: row.totalCount,
      isKnown: row.isKnown,
      lastUpdated: row.lastUpdated.toUtc(),
    );
  }
}
