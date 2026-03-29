import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:word_flow/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:word_flow/features/authentication/domain/usecases/sign_up_with_email.dart';
import 'package:word_flow/features/authentication/domain/usecases/sign_out.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/adopt_guest_words.dart';
import 'package:word_flow/features/authentication/domain/entities/user_entity.dart';
import 'package:word_flow/features/authentication/presentation/blocs/auth_state.dart';
import 'package:word_flow/features/authentication/presentation/blocs/auth_cubit_actions.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

@injectable
class AuthCubit extends Cubit<AuthState> with AuthCubitActions {
  AuthCubit(
    this.signInUseCase,
    this.signUpUseCase,
    this.signOutUseCase,
    this.wordRepository,
    this.adoptGuestWordsUseCase,
  ) : super(const AuthState.initial());

  @override final SignInWithEmail signInUseCase;
  @override final SignUpWithEmail signUpUseCase;
  @override final SignOut signOutUseCase;
  @override final WordRepository wordRepository;
  @override final AdoptGuestWords adoptGuestWordsUseCase;

  StreamSubscription? _authSubscription;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    emit(const AuthState.loading());
    _checkInitialSession();
    await _authSubscription?.cancel();
    _authSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange.listen(_handleAuthStateChange);
  }

  void _checkInitialSession() {
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
  }

  void _handleAuthStateChange(supabase.AuthState data) {
    if (isClosed) return;
    switch (data.event) {
      case supabase.AuthChangeEvent.signedIn:
      case supabase.AuthChangeEvent.tokenRefreshed:
      case supabase.AuthChangeEvent.userUpdated:
        final user = data.session?.user;
        if (user != null) {
          emit(AuthState.authenticated(UserEntity(id: user.id, email: user.email ?? '')));
          _updateSentryUser(user.id);
        }
      case supabase.AuthChangeEvent.signedOut:
        _updateSentryUser(null);
        emit(const AuthState.guest());
      default:
        break;
    }
  }

  void _updateSentryUser(String? id) {
    try {
      Sentry.configureScope((scope) => scope.setUser(id == null ? null : SentryUser(id: id)));
    } catch (_) {}
  }

  Future<void> mergeAndSignIn(UserEntity user) async {
    emit(const AuthState.loading());
    await adoptGuestWordsUseCase(user.id);
    emit(AuthState.authenticated(user));
  }

  Future<void> discardGuestAndSignIn(UserEntity user) async {
    emit(const AuthState.loading());
    await wordRepository.clearLocalWords(userId: null);
    emit(AuthState.authenticated(user));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
