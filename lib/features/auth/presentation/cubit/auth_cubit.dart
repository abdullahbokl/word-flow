import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../../../features/words/domain/repositories/word_repository.dart';
import '../../../../features/words/domain/usecases/adopt_guest_words.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final SignInWithEmail _signIn;
  final SignUpWithEmail _signUp;
  final SignOut _signOut;
  final AuthRepository _repository;
  final WordRepository _wordRepository;
  final AdoptGuestWords _adoptGuestWords;
  StreamSubscription? _authSubscription;

  AuthCubit(
    this._signIn,
    this._signUp,
    this._signOut,
    this._repository,
    this._wordRepository,
    this._adoptGuestWords,
  ) : super(const AuthState.initial()) {
    _init();
  }

  void _init() {
    _authSubscription = _repository.userStream.listen((user) {
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.guest());
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthState.loading());
    final result = await _signIn(email: email, password: password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) async {
        await _adoptGuestWords(user.id);
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> signUp(String email, String password) async {
    emit(const AuthState.loading());
    final result = await _signUp(email: email, password: password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) async {
        await _adoptGuestWords(user.id);
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> logOut() async {
    emit(const AuthState.loading());
    final user = state.maybeMap(authenticated: (s) => s.user, orElse: () => null);
    final result = await _signOut();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) async {
        if (user != null) {
          await _wordRepository.clearLocalWords(userId: user.id);
        }
        emit(const AuthState.guest());
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
