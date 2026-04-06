import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

// ---------------------------------------------------------------------------
// UseCase base types — categorization markers, each use case defines its own
// [call] signature.
// ---------------------------------------------------------------------------

/// Async use-case returning [TaskEither]. Preferred pattern.
abstract class AsyncUseCase<Type, Params> {
  const AsyncUseCase();
}

/// Stream-based use-case returning a live stream of [Either] results.
abstract class StreamUseCase<Type, Params> {
  const StreamUseCase();
}

/// Future-based use-case returning [Either]. Used when the repository already
/// returns [Future<Either>] and no TaskEither composition is needed.
abstract class FutureUseCase<Type, Params> {
  const FutureUseCase();
}

// ---------------------------------------------------------------------------
// Parameter objects
// ---------------------------------------------------------------------------

/// Marker for use-cases that take no parameters.
class NoParams {
  const NoParams();
}

/// Parameter object for word queries (filter + sort + search).
class WordQueryParams {
  const WordQueryParams({
    required this.filter,
    required this.sort,
    required this.query,
  });
  final String filter;
  final String sort;
  final String query;
}
