import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/sync/sync_preferences.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class SignOutAndClearLocal {
  SignOutAndClearLocal(
    this.authRepository,
    this.wordRepository,
    this.syncPreferences,
    this.logger,
  );

  final AuthRepository authRepository;
  final WordRepository wordRepository;
  final SyncPreferences syncPreferences;
  final AppLogger logger;

  Future<Either<Failure, void>> call() async {
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

        try {
          // Clear per-user sync cursor to avoid stale pull windows next login.
          await syncPreferences.clearUserTimestamp(userId);
        } catch (e, stackTrace) {
          logger.error(
            'SignOutAndClearLocal cleanup failed at clear user timestamp',
            e,
            stackTrace,
          );
        }
      }

      // Also clear any remaining guest words.
      await trackCleanupFailure(
        await wordRepository.clearGuestWords(),
        'clear guest words',
      );
    } catch (e, stackTrace) {
      logger.error(
        'SignOutAndClearLocal unexpected cleanup error',
        e,
        stackTrace,
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
