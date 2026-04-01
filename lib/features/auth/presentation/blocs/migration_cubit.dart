import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/features/auth/data/services/migration_service.dart';
import 'package:word_flow/core/utils/rate_limiter.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/blocs/migration_state.dart';

@lazySingleton
class MigrationCubit extends Cubit<MigrationState> {
  MigrationCubit(
    this.signInUseCase,
    this.signUpUseCase,
    this.migrationService,
    this.authCubit,
    @Named('migration_rate_limiter') this._rateLimiter,
  ) : super(const MigrationState.initial()) {
    unawaited(_rateLimiter.initialize());
  }

  final SignInWithEmailUseCase signInUseCase;
  final SignUpWithEmailUseCase signUpUseCase;
  final MigrationService migrationService;
  final AuthCubit authCubit;
  final RateLimiter _rateLimiter;

  Future<void> signIn(String email, String password) async {
    if (!_rateLimiter.canAttempt()) {
      emit(
        MigrationState.rateLimited(
          _rateLimiter.remainingCooldown ?? Duration.zero,
        ),
      );
      return;
    }
    await _rateLimiter.recordAttempt();

    emit(const MigrationState.loading());
    final result = await signInUseCase(email, password);
    await result.fold(
      (failure) async => emit(MigrationState.error(failure.message)),
      (user) async {
        final guestRes = await migrationService.getGuestWordsCount();
        final guestCount = guestRes.fold((_) => 0, (count) => count);
        if (guestCount > 0) {
          emit(MigrationState.pendingMerge(user, guestCount));
        } else {
          await _rateLimiter.reset();
          authCubit.onAuthenticatedWithMerge(user);
          emit(const MigrationState.success());
        }
      },
    );
  }

  Future<void> signUp(String email, String password) async {
    if (!_rateLimiter.canAttempt()) {
      emit(
        MigrationState.rateLimited(
          _rateLimiter.remainingCooldown ?? Duration.zero,
        ),
      );
      return;
    }
    await _rateLimiter.recordAttempt();

    emit(const MigrationState.loading());
    final result = await signUpUseCase(email, password);
    await result.fold(
      (failure) async => emit(MigrationState.error(failure.message)),
      (user) async {
        await _rateLimiter.reset();
        final migrationResult = await migrationService.migrateGuestData(
          user.id,
        );
        migrationResult.fold(
          (failure) {
            // Sign-up succeeded but migration failed. Show error with retry option.
            // The user IS authenticated but guest words were not migrated.
            emit(
              MigrationState.error(
                'Account created but vocabulary migration failed: ${failure.message}. '
                'Please try signing in again to retry migration.',
              ),
            );
            // Still authenticate the user — account was created successfully.
            authCubit.onAuthenticatedWithMerge(user);
          },
          (count) {
            authCubit.onAuthenticatedWithMerge(user);
            emit(const MigrationState.success());
          },
        );
      },
    );
  }

  Future<void> mergeAndSignIn(AuthUser user) async {
    emit(const MigrationState.loading());
    await migrationService.migrateGuestData(user.id);
    authCubit.onAuthenticatedWithMerge(user);
    emit(const MigrationState.success());
  }

  Future<void> discardGuestAndSignIn(AuthUser user) async {
    emit(const MigrationState.loading());
    await migrationService.discardGuestData();
    authCubit.onAuthenticatedWithDiscard(user);
    emit(const MigrationState.success());
  }

  void reset() {
    emit(const MigrationState.initial());
  }
}
