import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/features/vocabulary/data/sync/sync_orchestrator.dart';
import 'package:word_flow/features/vocabulary/data/sync/sync_preferences.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class SignOutAndClearLocal {
  SignOutAndClearLocal(
    this.authRepository,
    this.wordRepository,
    this.syncPreferences,
    this.logger,
    this.syncOrchestrator,
  );

  final AuthRepository authRepository;
  final WordRepository wordRepository;
  final SyncPreferences syncPreferences;
  final AppLogger logger;
  final SyncOrchestrator syncOrchestrator;

  Future<Either<Failure, void>> call() async {
    // Cancel any in-flight sync BEFORE clearing local data to avoid writing deleted words remotely.
    syncOrchestrator.cancelInFlightSync();

    // Capture current user before sign-out so we can clear that user's local data.
    final userId = authRepository.currentUserId;

    Future<void> trackCleanupFailure(
      Either<Failure, void> result,
      String step,
    ) async {
      result.fold((failure) {
        logger.error(
          'SignOutAndClearLocal cleanup failed at $step: ${failure.message}',
        );
      }, (_) {});
    }

    try {
      if (userId != null) {
        // Clear authenticated user-local words first.
        await trackCleanupFailure(
          await wordRepository.clearLocalWords(userId),
          'clear authenticated user words',
        );
      }

      // Also clear any remaining guest words.
      await trackCleanupFailure(
        await wordRepository.clearGuestWords(),
        'clear guest words',
      );

      try {
        // Clear ALL sync cursors unconditionally — handles dirty sign-out where userId may be null.
        await syncPreferences.clearAllTimestamps();
      } catch (e, stackTrace) {
        logger.error(
          'SignOutAndClearLocal cleanup failed at clear all sync timestamps',
          error: e,
          stackTrace: stackTrace,
          category: LogCategory.auth,
        );
      }
    } catch (e, stackTrace) {
      logger.error(
        'SignOutAndClearLocal unexpected cleanup error',
        error: e,
        stackTrace: stackTrace,
        category: LogCategory.auth,
      );
    }

    final signOutResult = await authRepository.signOut();

    return signOutResult.fold(
      (failure) => Left(failure),
      // Cleanup failures are logged above but do not block sign-out.
      (_) => const Right(null),
    );
  }
}
