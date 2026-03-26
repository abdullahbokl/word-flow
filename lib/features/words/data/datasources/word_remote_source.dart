import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../models/word_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class WordRemoteSource {
  Future<void> upsertWord(WordModel word);
  Future<void> deleteWord(String id);
  Future<List<WordModel>> fetchUserWords(String userId);
}

@LazySingleton(as: WordRemoteSource)
class WordRemoteSourceImpl implements WordRemoteSource {
  final DioClient _dioClient;

  WordRemoteSourceImpl(this._dioClient);

  @override
  Future<void> upsertWord(WordModel word) async {
    try {
      await _dioClient.instance.post(
        'words',
        data: word.toRemoteMap(),
        queryParameters: {'on_conflict': 'id'},
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteWord(String id) async {
    try {
      await _dioClient.instance.delete(
        'words',
        queryParameters: {'id': 'eq.$id'},
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<WordModel>> fetchUserWords(String userId) async {
    try {
      final response = await _dioClient.instance.get(
        'words',
        queryParameters: {'user_id': 'eq.$userId'},
      );
      return (response.data as List)
          .map((m) => WordModel.fromMap(m))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
