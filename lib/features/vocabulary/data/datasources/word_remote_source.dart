import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/features/vocabulary/data/models/word_remote_dto.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/errors/exceptions.dart';

class PaginatedSyncResult {
  const PaginatedSyncResult({
    required this.words,
    required this.hasMore,
  });

  final List<WordRemoteDto> words;
  final bool hasMore;
}

abstract class WordRemoteSource {
  Future<void> upsertWord(WordRemoteDto word);
  Future<void> deleteWord(String id);
  Future<Either<Failure, PaginatedSyncResult>> fetchUserWords(String userId, {int limit = 500, int offset = 0});
  Future<Either<Failure, PaginatedSyncResult>> fetchWordsUpdatedSince(String userId, DateTime since, {int limit = 500, int offset = 0});
}

class WordRemoteSourceImpl implements WordRemoteSource {

  WordRemoteSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<void> upsertWord(WordRemoteDto word) async {
    try {
      // Sync uses Last-Writer-Wins (LWW) semantics.
      // We use a custom RPC function to handle the LWW merge logic on the server.
      final json = word.toJson();
      await _client.rpc(
        'upsert_word_lww',
        params: {
          'p_id': json['id'],
          'p_user_id': json['user_id'],
          'p_word_text': json['word_text'],
          'p_total_count': json['total_count'],
          'p_is_known': json['is_known'],
          'p_last_updated': json['last_updated'],
        },
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
  Future<Either<Failure, PaginatedSyncResult>> fetchUserWords(
    String userId, {
    int limit = 500,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('words')
          .select()
          // Note: The '.eq('user_id', userId)' filter is technically redundant 
          // because of Row Level Security (RLS) policies on the backend, 
          // but we keep it here for clarity and performance hints for the query planner.
          .eq('user_id', userId)
          .order('id', ascending: true)
          .range(offset, offset + limit - 1);
      
      final data = response as List<dynamic>;
      try {
        final dtos = data.map((m) => WordRemoteDto.fromJson(m as Map<String, dynamic>)).toList();
        return Right(PaginatedSyncResult(words: dtos, hasMore: dtos.length == limit));
      } catch (e) {
        return Left(ServerFailure('Invalid server response: $e'));
      }
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedSyncResult>> fetchWordsUpdatedSince(
    String userId,
    DateTime since, {
    int limit = 500,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('words')
          .select()
          .eq('user_id', userId)
          .gte('last_updated', since.toUtc().toIso8601String())
          .order('last_updated', ascending: true)
          .order('id', ascending: true)
          .range(offset, offset + limit - 1);

      final data = response as List<dynamic>;
      try {
        final dtos = data.map((m) => WordRemoteDto.fromJson(m as Map<String, dynamic>)).toList();
        return Right(PaginatedSyncResult(words: dtos, hasMore: dtos.length == limit));
      } catch (e) {
        return Left(ServerFailure('Invalid server response during delta fetch: $e'));
      }
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class DisabledWordRemoteSource implements WordRemoteSource {
  @override
  Future<void> deleteWord(String id) async {
    // No-op for disabled backend. A real application might queue this, 
    // but here we just return or throw since the remote source isn't configured.
    // However, the interface returns Future<void>, so we just complete.
    // SyncRepositoryImpl checks if remote is configured so it shouldn't be called,
    // but if it is, it just silently does nothing or throws.
    // To match instructions: "returns Left(ConnectionFailure...)" but deleteWord is Future<void>.
    // So for Future<void>, we can just throw or complete.
    // Let's throw an exception to be safe and let caller catch it.
    throw ServerException('Remote sync not configured');
  }

  @override
  Future<Either<Failure, PaginatedSyncResult>> fetchUserWords(String userId, {int limit = 500, int offset = 0}) async {
    return const Left(ConnectionFailure('Remote sync not configured'));
  }

  @override
  Future<Either<Failure, PaginatedSyncResult>> fetchWordsUpdatedSince(String userId, DateTime since, {int limit = 500, int offset = 0}) async {
    return const Left(ConnectionFailure('Remote sync not configured'));
  }

  @override
  Future<void> upsertWord(WordRemoteDto word) async {
    throw ServerException('Remote sync not configured');
  }
}
