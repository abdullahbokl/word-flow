import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/utils/rate_limiter.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_out_and_clear_local.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_state.dart';

mixin AuthCubitActions on Cubit<AuthState> {
  SignInWithEmailUseCase get signInUseCase;
  SignUpWithEmailUseCase get signUpUseCase;
  SignOutAndClearLocal get signOutAndClearLocalUseCase;
  RateLimiter get rateLimiter;

  Future<void> signIn(String email, String password) async {
    if (!rateLimiter.canAttempt()) {
      emit(
        AuthState.rateLimited(rateLimiter.remainingCooldown ?? Duration.zero),
      );
      return;
    }
    await rateLimiter.recordAttempt();

    emit(const AuthState.loading());
    final result = await signInUseCase(email, password);
    await result.fold(
      (failure) async => emit(AuthState.error(failure.message)),
      (user) async {
        await rateLimiter.reset();
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> signUp(String email, String password) async {
    if (!rateLimiter.canAttempt()) {
      emit(
        AuthState.rateLimited(rateLimiter.remainingCooldown ?? Duration.zero),
      );
      return;
    }
    await rateLimiter.recordAttempt();

    emit(const AuthState.loading());
    final result = await signUpUseCase(email, password);
    await result.fold(
      (failure) async => emit(AuthState.error(failure.message)),
      (user) async {
        await rateLimiter.reset();
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> logOut() async {
    emit(const AuthState.loading());
    final result = await signOutAndClearLocalUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.guest()),
    );
  }
}
