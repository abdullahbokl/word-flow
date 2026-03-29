import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/features/vocabulary/data/models/word_remote_dto.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/errors/exceptions.dart';

abstract class WordRemoteSource {
  Future<void> upsertWord(WordRemoteDto word);
  Future<void> deleteWord(String id);
  Future<Either<Failure, List<WordRemoteDto>>> fetchUserWords(String userId);
}

@LazySingleton(as: WordRemoteSource)
class WordRemoteSourceImpl implements WordRemoteSource {

  WordRemoteSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<void> upsertWord(WordRemoteDto word) async {
    try {
      // Sync uses Last-Writer-Wins (LWW) semantics based on 'id'.
      // Row-Level Security (RLS) handles authorization on the backend.
      await _client.from('words').upsert(
            word.toJson(),
            onConflict: 'id',
            ignoreDuplicates: false,
          );
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
  Future<Either<Failure, List<WordRemoteDto>>> fetchUserWords(String userId) async {
    try {
      final response = await _client
          .from('words')
          .select()
          // Note: The '.eq('user_id', userId)' filter is technically redundant 
          // because of Row Level Security (RLS) policies on the backend, 
          // but we keep it here for clarity and performance hints for the query planner.
          .eq('user_id', userId);
      
      final data = response as List<dynamic>;
      try {
        final dtos = data.map((m) => WordRemoteDto.fromJson(m as Map<String, dynamic>)).toList();
        return Right(dtos);
      } catch (e) {
        return Left(ServerFailure('Invalid server response: $e'));
      }
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
