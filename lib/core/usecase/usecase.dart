import 'package:fpdart/fpdart.dart';
import 'package:lexitrack/core/error/failures.dart';

/// Standard abstract UseCase class.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Async use-case base using [TaskEither].
abstract class AsyncUseCase<TReturn, Params> {
  const AsyncUseCase();
  TaskEither<Failure, TReturn> call(Params params);
}

/// Stream-based use-case base.
abstract class StreamUseCase<TReturn, Params> {
  const StreamUseCase();
  Stream<Either<Failure, TReturn>> call(Params params);
}

/// Future-based use-case base.
abstract class FutureUseCase<TReturn, Params> {
  const FutureUseCase();
  Future<Either<Failure, TReturn>> call(Params params);
}

// ---------------------------------------------------------------------------
// Parameter objects
// ---------------------------------------------------------------------------

/// Marker for use-cases that take no parameters.
class NoParams {
  const NoParams();
}
