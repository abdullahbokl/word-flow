import 'package:injectable/injectable.dart';
import 'package:word_flow/core/database/app_database.dart';


abstract class WordLocalSource {
  Future<void> saveWord(WordsCompanion word);
  Future<void> saveWords(List<WordsCompanion> words);
  Future<void> saveWordsInTransaction(List<WordsCompanion> companions);
  Future<Map<String, WordRow>> getWordTextMap({String? userId});
  Future<List<WordRow>> getWords({String? userId});
  Future<List<WordRow>> getWordsByTexts(List<String> texts, {String? userId});
  Future<List<String>> getKnownWordTexts({String? userId});
  Future<WordRow?> getWordById(String id);
  Future<WordRow?> getWordByText(String text, {String? userId});
  Future<void> deleteWord(String id);
  Stream<List<WordRow>> watchWords({String? userId});
  Future<int> adoptGuestWords(String userId);
  Future<void> clearLocalWords({String? userId});
  Future<int> getGuestWordsCount();
}

@LazySingleton(as: WordLocalSource)
class WordLocalSourceImpl implements WordLocalSource {

  WordLocalSourceImpl(this._db);
  final WordFlowDatabase _db;

  @override
  Future<void> saveWord(WordsCompanion word) async {
    await _db.upsertWord(word);
  }

  @override
  Future<void> saveWords(List<WordsCompanion> words) async {
    await _db.upsertWords(words);
  }

  @override
  Future<void> saveWordsInTransaction(List<WordsCompanion> companions) async {
    // All page writes must commit atomically to avoid partial pull application.
    await _db.upsertWordsInTransaction(companions);
  }

  @override
  Future<Map<String, WordRow>> getWordTextMap({String? userId}) async {
    final query = _db.select(_db.words);
    if (userId != null) {
      query.where((t) => t.userId.equals(userId));
    } else {
      query.where((t) => t.userId.isNull());
    }
    final rows = await query.get();
    return {for (final row in rows) row.wordText: row};
  }

  @override
  Future<int> getGuestWordsCount() async {
    return _db.getGuestWordsCount();
  }

  @override
  Future<List<WordRow>> getWords({String? userId}) async {
    return _db.watchWords(userId: userId).first;
  }

  @override
  Future<List<WordRow>> getWordsByTexts(List<String> texts, {String? userId}) async {
    return _db.getWordsByTexts(texts, userId: userId);
  }

  @override
  Future<List<String>> getKnownWordTexts({String? userId}) async {
    return _db.getKnownWordTexts(userId: userId);
  }

  @override
  Future<WordRow?> getWordById(String id) async {
    return _db.getWordById(id);
  }

  @override
  Future<WordRow?> getWordByText(String text, {String? userId}) async {
    return _db.getWordByText(text, userId: userId);
  }

  @override
  Future<void> deleteWord(String id) async {
    await _db.deleteWordById(id);
  }

  @override
  Stream<List<WordRow>> watchWords({String? userId}) {
    return _db.watchWords(userId: userId);
  }

  @override
  Future<int> adoptGuestWords(String userId) async {
    return _db.adoptGuestWords(userId);
  }

  @override
  Future<void> clearLocalWords({String? userId}) async {
    await _db.clearLocalWords(userId: userId);
  }
}
