import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:word_flow/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_out.dart';
import 'package:word_flow/features/words/domain/repositories/word_repository.dart';
import 'package:word_flow/features/words/domain/usecases/adopt_guest_words.dart';
import 'package:word_flow/features/auth/domain/entities/user_entity.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {

  AuthCubit(
    this._signIn,
    this._signUp,
    this._signOut,
    this._wordRepository,
    this._adoptGuestWords,
  ) : super(const AuthState.initial());
  final SignInWithEmail _signIn;
  final SignUpWithEmail _signUp;
  final SignOut _signOut;
  final WordRepository _wordRepository;
  final AdoptGuestWords _adoptGuestWords;
  StreamSubscription? _authSubscription;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    emit(const AuthState.loading());

    try {
      final session = supabase.Supabase.instance.client.auth.currentSession;
      final user = session?.user;
      if (session != null && user != null) {
        emit(AuthState.authenticated(UserEntity(id: user.id, email: user.email ?? '')));
      } else {
        emit(const AuthState.guest());
      }
    } catch (_) {
      emit(const AuthState.guest());
    }

    await _authSubscription?.cancel();
    _authSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
      if (isClosed) return;

      switch (data.event) {
        case supabase.AuthChangeEvent.signedIn:
        case supabase.AuthChangeEvent.tokenRefreshed:
        case supabase.AuthChangeEvent.userUpdated:
          final user = data.session?.user;
          if (user != null) {
            emit(
              AuthState.authenticated(
                UserEntity(id: user.id, email: user.email ?? ''),
              ),
            );
          }
          break;
        case supabase.AuthChangeEvent.signedOut:
          emit(const AuthState.guest());
          break;
        default:
          break;
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthState.loading());
    final result = await _signIn(email: email, password: password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) async {
        final guestCountResult = await _wordRepository.getGuestWordsCount();
        final guestCount = guestCountResult.fold((_) => 0, (count) => count);

        if (guestCount > 0) {
          emit(AuthState.pendingMerge(user, guestCount));
        } else {
          emit(AuthState.authenticated(user));
        }
      },
    );
  }

  Future<void> mergeAndSignIn(UserEntity user) async {
    emit(const AuthState.loading());
    await _adoptGuestWords(user.id);
    emit(AuthState.authenticated(user));
  }

  Future<void> discardGuestAndSignIn(UserEntity user) async {
    emit(const AuthState.loading());
    await _wordRepository.clearLocalWords(userId: null);
    emit(AuthState.authenticated(user));
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
