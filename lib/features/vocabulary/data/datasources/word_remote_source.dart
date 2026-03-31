import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/features/vocabulary/data/models/word_remote_dto.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/errors/exceptions.dart';

class PaginatedSyncResult {
  const PaginatedSyncResult({
    required this.words,
    this.nextCursorTime,
    this.nextCursorId,
  });

  final List<WordRemoteDto> words;
  final String? nextCursorTime;
  final String? nextCursorId;
}

abstract class WordRemoteSource {
  Future<void> upsertWord(WordRemoteDto word);
  Future<void> deleteWord(String id);
  Future<Either<Failure, PaginatedSyncResult>> fetchUserWords(
    String userId, {
    int limit = 500,
    String? cursorTime,
    String? cursorId,
  });
  Future<Either<Failure, PaginatedSyncResult>> fetchWordsUpdatedSince(
    String userId,
    DateTime since, {
    int limit = 500,
    String? cursorTime,
    String? cursorId,
  });
}

class WordRemoteSourceImpl implements WordRemoteSource {
  WordRemoteSourceImpl(this._client, this._logger);
  final SupabaseClient _client;
  final AppLogger _logger;

  @override
  Future<void> upsertWord(WordRemoteDto word) async {
    try {
      // Sync uses Last-Writer-Wins (LWW) semantics.
      // We use a custom RPC function to handle the LWW merge logic on the server.
      // p_server_timestamp is nullable; when null, Postgres trigger
      // (set_server_timestamp) sets it on INSERT. On UPDATE, the existing
      // server timestamp should be preserved by server-side merge rules.
      final json = word.toJson();
      final params = {
        'p_id': json['id'],
        'p_user_id': json['user_id'],
        'p_word_text': json['word_text'],
        'p_total_count': json['total_count'],
        'p_is_known': json['is_known'],
        'p_last_updated': json['last_updated'],
        'p_server_timestamp': json['server_timestamp'],
      };
      await _client.rpc('upsert_word_lww', params: params);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteWord(String id) async {
    // No-op when remote sync is disabled or when using a disabled remote source.
    // Deleting on a disabled backend should not throw — callers expect a
    // completed future and handle errors via the repository/failure flow.
    return;
  }

  @override
  Future<Either<Failure, PaginatedSyncResult>> fetchUserWords(
    String userId, {
    int limit = 500,
    String? cursorTime,
    String? cursorId,
  }) async {
    try {
      var query = _client
          .from('words')
          .select()
          // Note: The '.eq('user_id', userId)' filter is technically redundant
          // because of Row Level Security (RLS) policies on the backend,
          // but we keep it here for clarity and performance hints for the query planner.
          .eq('user_id', userId);

      if (cursorTime != null && cursorId != null) {
        query = query.or(
          'last_updated.gt.$cursorTime,and(last_updated.eq.$cursorTime,id.gt.$cursorId)',
        );
      }

      final dynamic response = await query
          .order('last_updated', ascending: true)
          .order('id', ascending: true)
          .limit(limit);

      // Guard before any cast: Supabase can return non-list payloads (null/map).
      if (response is! List) {
        final failure = ServerFailure(
          'Unexpected response format: ${response.runtimeType}',
        );
        _logger.error('fetchUserWords: unexpected response format', failure);
        return Left(failure);
      }
      final Object validatedResponse = response;

      try {
        // Parse is isolated so malformed rows become Failure instead of app crash.
        final rows = (validatedResponse as List).cast<Map<String, dynamic>>();
        final dtos = <WordRemoteDto>[];
        for (final row in rows) {
          dtos.add(WordRemoteDto.fromJson(row));
        }
        final hasNextPage = dtos.length == limit;
        final last = hasNextPage ? dtos.last : null;
        return Right(
          PaginatedSyncResult(
            words: dtos,
            nextCursorTime: last?.lastUpdated.toUtc().toIso8601String(),
            nextCursorId: last?.id,
          ),
        );
      } catch (e, stackTrace) {
        final failure = ServerFailure('Failed to parse word: $e');
        _logger.error(
          'fetchUserWords: failed to parse word',
          failure,
          stackTrace,
        );
        return Left(failure);
      }
    } on PostgrestException catch (e, stackTrace) {
      final failure = ServerFailure(e.message);
      _logger.error('fetchUserWords: postgrest exception', failure, stackTrace);
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(e.toString());
      _logger.error(
        'fetchUserWords: unexpected exception',
        failure,
        StackTrace.current,
      );
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, PaginatedSyncResult>> fetchWordsUpdatedSince(
    String userId,
    DateTime since, {
    int limit = 500,
    String? cursorTime,
    String? cursorId,
  }) async {
    try {
      var query = _client
          .from('words')
          .select()
          .eq('user_id', userId)
          .gte('last_updated', since.toUtc().toIso8601String());

      if (cursorTime != null && cursorId != null) {
        query = query.or(
          'last_updated.gt.$cursorTime,and(last_updated.eq.$cursorTime,id.gt.$cursorId)',
        );
      }

      final dynamic response = await query
          .order('last_updated', ascending: true)
          .order('id', ascending: true)
          .limit(limit);

      // Guard before any cast: Supabase can return non-list payloads (null/map).
      if (response is! List) {
        final failure = ServerFailure(
          'Unexpected response format: ${response.runtimeType}',
        );
        _logger.error(
          'fetchWordsUpdatedSince: unexpected response format',
          failure,
        );
        return Left(failure);
      }
      final Object validatedResponse = response;

      try {
        // Parse is isolated so malformed rows become Failure instead of app crash.
        final rows = (validatedResponse as List).cast<Map<String, dynamic>>();
        final dtos = <WordRemoteDto>[];
        for (final row in rows) {
          dtos.add(WordRemoteDto.fromJson(row));
        }
        final hasNextPage = dtos.length == limit;
        final last = hasNextPage ? dtos.last : null;
        return Right(
          PaginatedSyncResult(
            words: dtos,
            nextCursorTime: last?.lastUpdated.toUtc().toIso8601String(),
            nextCursorId: last?.id,
          ),
        );
      } catch (e, stackTrace) {
        final failure = ServerFailure('Failed to parse word: $e');
        _logger.error(
          'fetchWordsUpdatedSince: failed to parse word',
          failure,
          stackTrace,
        );
        return Left(failure);
      }
    } on PostgrestException catch (e, stackTrace) {
      final failure = ServerFailure(e.message);
      _logger.error(
        'fetchWordsUpdatedSince: postgrest exception',
        failure,
        stackTrace,
      );
      return Left(failure);
    } catch (e) {
      final failure = ServerFailure(e.toString());
      _logger.error(
        'fetchWordsUpdatedSince: unexpected exception',
        failure,
        StackTrace.current,
      );
      return Left(failure);
    }
  }
}

class DisabledWordRemoteSource implements WordRemoteSource {
  @override
  Future<void> deleteWord(String id) async {
    // Intentionally complete as a no-op: remote is disabled.
    return;
  }

  @override
  Future<Either<Failure, PaginatedSyncResult>> fetchUserWords(
    String userId, {
    int limit = 500,
    String? cursorTime,
    String? cursorId,
  }) async {
    return const Left(ConnectionFailure('Remote sync not configured'));
  }

  @override
  Future<Either<Failure, PaginatedSyncResult>> fetchWordsUpdatedSince(
    String userId,
    DateTime since, {
    int limit = 500,
    String? cursorTime,
    String? cursorId,
  }) async {
    return const Left(ConnectionFailure('Remote sync not configured'));
  }

  @override
  Future<void> upsertWord(WordRemoteDto word) async {
    // No-op when remote sync is disabled. Prevents callers from crashing
    // if a guard is ever bypassed; repository layer should surface failures
    // via `Either<Failure, ...>` when appropriate.
    return;
  }
}
