import 'dart:async';
import 'dart:io';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:word_flow/core/logging/app_logger.dart';

/// Centralised error mapping utility.
///
/// All repository implementations should delegate raw exception handling to this
/// class. It logs the original error via the provided [AppLogger] and reports to
/// Sentry for any non‑authentication errors.
class ErrorMapper {
  /// Maps a caught exception to a concrete [Failure] implementation.
  ///
  /// The [logger] is used to record the raw error and stack trace.
  /// Sentry is automatically notified for all errors except those derived
  /// from [AuthException].
  static Failure mapException(
    dynamic error,
    StackTrace stackTrace,
    AppLogger logger,
  ) {
    // Log the raw error first – this is always useful for debugging.
    logger.error('Exception caught in repository', error, stackTrace);

    // Report to Sentry for non‑auth errors.
    if (error is! AuthException) {
      try {
        Sentry.captureException(error, stackTrace: stackTrace);
      } catch (_) {}
    }

    // Map specific exception types to domain failures.
    if (error is AuthException) {
      return AuthFailure(error.message ?? 'Authentication error occurred');
    }
    if (error is ServerException) {
      return ServerFailure('A server error occurred');
    }
    if (error is PostgrestException) {
      // Supabase client wraps HTTP errors in PostgrestException.
      return ServerFailure('A server error occurred');
    }
    if (error is DatabaseException) {
      return DatabaseFailure('A database error occurred');
    }
    if (error is TimeoutException) {
      return ConnectionFailure('A connection timeout occurred');
    }
    if (error is SocketException) {
      return ConnectionFailure('A network connection error occurred');
    }
    // Fallback – unknown error type.
    return ServerFailure('An unexpected error occurred');
  }
}
