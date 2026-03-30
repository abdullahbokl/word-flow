import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_out_and_clear_local.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_state.dart';

mixin AuthCubitActions on Cubit<AuthState> {
  SignInWithEmailUseCase get signInUseCase;
  SignUpWithEmailUseCase get signUpUseCase;
  SignOutAndClearLocal get signOutAndClearLocalUseCase;

  Future<void> signIn(String email, String password) async {
    emit(const AuthState.loading());
    final result = await signInUseCase(email, password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) {
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> signUp(String email, String password) async {
    emit(const AuthState.loading());
    final result = await signUpUseCase(email, password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) {
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

