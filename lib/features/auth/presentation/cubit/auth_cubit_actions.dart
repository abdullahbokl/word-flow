import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_out.dart';
import 'package:word_flow/features/words/domain/repositories/word_repository.dart';
import 'package:word_flow/features/words/domain/usecases/adopt_guest_words.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_state.dart';

mixin AuthCubitActions on Cubit<AuthState> {
  SignInWithEmail get signInUseCase;
  SignUpWithEmail get signUpUseCase;
  SignOut get signOutUseCase;
  WordRepository get wordRepository;
  AdoptGuestWords get adoptGuestWordsUseCase;

  Future<void> signIn(String email, String password) async {
    emit(const AuthState.loading());
    final result = await signInUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) async {
        final guestRes = await wordRepository.getGuestWordsCount();
        final guestCount = guestRes.fold((_) => 0, (count) => count);
        emit(guestCount > 0 ? AuthState.pendingMerge(user, guestCount) : AuthState.authenticated(user));
      },
    );
  }

  Future<void> signUp(String email, String password) async {
    emit(const AuthState.loading());
    final result = await signUpUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) async {
        await adoptGuestWordsUseCase(user.id);
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> logOut() async {
    emit(const AuthState.loading());
    final user = state.maybeMap(authenticated: (s) => s.user, orElse: () => null);
    final result = await signOutUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) async {
        if (user != null) await wordRepository.clearLocalWords(userId: user.id);
        emit(const AuthState.guest());
      },
    );
  }
}
