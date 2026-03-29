import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/entities/auth_state_change.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_out_and_clear_local.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/adopt_guest_words.dart';
import 'package:word_flow/features/authentication/presentation/blocs/auth_state.dart';
import 'package:word_flow/features/authentication/presentation/blocs/auth_cubit_actions.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

@injectable
class AuthCubit extends Cubit<AuthState> with AuthCubitActions {
  AuthCubit(
    this.authRepository,
    this.signInUseCase,
    this.signUpUseCase,
    this.signOutAndClearLocalUseCase,
    this.wordRepository,
    this.adoptGuestWordsUseCase,
  ) : super(const AuthState.initial());

  final AuthRepository authRepository;
  @override final SignInWithEmailUseCase signInUseCase;
  @override final SignUpWithEmailUseCase signUpUseCase;
  @override final SignOutAndClearLocal signOutAndClearLocalUseCase;
  @override final WordRepository wordRepository;
  @override final AdoptGuestWords adoptGuestWordsUseCase;

  String? get currentUserId => authRepository.currentUserId;

  StreamSubscription? _authSubscription;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    emit(const AuthState.loading());
    _checkInitialSession();
    await _authSubscription?.cancel();
    _authSubscription = authRepository.authStateStream.listen(_handleAuthStateChange);
  }

  void _checkInitialSession() {
    try {
      final user = authRepository.currentUser;
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.guest());
      }
    } catch (_) {
      emit(const AuthState.guest());
    }
  }

  void _handleAuthStateChange(AuthStateChange event) {
    if (isClosed) return;
    
    final user = authRepository.currentUser;
    
    switch (event) {
      case AuthStateChange.signedIn:
      case AuthStateChange.tokenRefreshed:
      case AuthStateChange.userUpdated:
        if (user != null) {
          emit(AuthState.authenticated(user));
          _updateSentryUser(user.id);
        }
        break;
      case AuthStateChange.signedOut:
        _updateSentryUser(null);
        emit(const AuthState.guest());
        break;
      default:
        break;
    }
  }

  void _updateSentryUser(String? id) {
    try {
      Sentry.configureScope((scope) => scope.setUser(id == null ? null : SentryUser(id: id)));
    } catch (_) {}
  }

  Future<void> mergeAndSignIn(AuthUser user) async {
    emit(const AuthState.loading());
    await adoptGuestWordsUseCase(user.id);
    emit(AuthState.authenticated(user));
  }

  Future<void> discardGuestAndSignIn(AuthUser user) async {
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
