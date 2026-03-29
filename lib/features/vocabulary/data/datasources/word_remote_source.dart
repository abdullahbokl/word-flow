import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/features/vocabulary/data/models/word_model.dart';
import 'package:word_flow/core/errors/exceptions.dart';

abstract class WordRemoteSource {
  Future<void> upsertWord(WordModel word);
  Future<void> deleteWord(String id);
  Future<List<WordModel>> fetchUserWords(String userId);
}

@LazySingleton(as: WordRemoteSource)
class WordRemoteSourceImpl implements WordRemoteSource {

  WordRemoteSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<void> upsertWord(WordModel word) async {
    try {
      await _client.from('words').upsert(word.toRemoteMap());
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteWord(String id) async {
    try {
      await _client.from('words').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<WordModel>> fetchUserWords(String userId) async {
    try {
      final response = await _client
          .from('words')
          .select()
          .eq('user_id', userId);
      return (response as List<dynamic>)
          .map((m) => WordModel.fromMap(m as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
