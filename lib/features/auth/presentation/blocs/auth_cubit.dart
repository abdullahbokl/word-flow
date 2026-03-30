import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/utils/rate_limiter.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/entities/auth_state_change.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_out_and_clear_local.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_state.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this.authRepository,
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutAndClearLocalUseCase,
    @Named('auth_rate_limiter') this._rateLimiter,
  ) : super(const AuthState.initial());

  final SignInWithEmailUseCase _signInUseCase;
  final SignUpWithEmailUseCase _signUpUseCase;
  final SignOutAndClearLocal _signOutAndClearLocalUseCase;
  final RateLimiter _rateLimiter;
  final AppLogger _logger = AppLogger();

  final AuthRepository authRepository;

  String? get currentUserId => authRepository.currentUserId;

  StreamSubscription? _authSubscription;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    await _rateLimiter.initialize();
    emit(const AuthState.loading());
    _checkInitialSession();
    await _authSubscription?.cancel();
    _authSubscription = authRepository.authStateStream.listen(
      _handleAuthStateChange,
    );
  }

  void _checkInitialSession() {
    try {
      final user = authRepository.currentUser;
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.guest());
      }
    } catch (e) {
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
      case AuthStateChange.passwordRecovery:
        emit(const AuthState.passwordRecovery());
        break;
      case AuthStateChange.signedOut:
        _updateSentryUser(null);
        emit(const AuthState.guest());
        break;
      case AuthStateChange.unknown:
        _logger.warning('Unknown auth event received — re-checking session');
        _checkInitialSession();
        break;
    }
  }

  void _updateSentryUser(String? id) {
    try {
      Sentry.configureScope(
        (scope) => scope.setUser(id == null ? null : SentryUser(id: id)),
      );
    } catch (_) {}
  }

  void onAuthenticatedWithMerge(AuthUser user) {
    emit(AuthState.authenticated(user));
  }

  void onAuthenticatedWithDiscard(AuthUser user) {
    emit(AuthState.authenticated(user));
  }

  Future<void> signIn(String email, String password) async {
    await _signIn(email, password);
  }

  Future<void> signUp(String email, String password) async {
    await _signUp(email, password);
  }

  Future<void> logOut() async {
    await _logOut();
  }

  Future<void> _signIn(String email, String password) async {
    if (!_rateLimiter.canAttempt()) {
      emit(
        AuthState.rateLimited(_rateLimiter.remainingCooldown ?? Duration.zero),
      );
      return;
    }
    await _rateLimiter.recordAttempt();

    emit(const AuthState.loading());
    final result = await _signInUseCase(email, password);
    await result.fold(
      (failure) async => emit(AuthState.error(failure.message)),
      (user) async {
        await _rateLimiter.reset();
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> _signUp(String email, String password) async {
    if (!_rateLimiter.canAttempt()) {
      emit(
        AuthState.rateLimited(_rateLimiter.remainingCooldown ?? Duration.zero),
      );
      return;
    }
    await _rateLimiter.recordAttempt();

    emit(const AuthState.loading());
    final result = await _signUpUseCase(email, password);
    await result.fold(
      (failure) async => emit(AuthState.error(failure.message)),
      (user) async {
        await _rateLimiter.reset();
        emit(AuthState.authenticated(user));
      },
    );
  }

  Future<void> _logOut() async {
    emit(const AuthState.loading());
    final result = await _signOutAndClearLocalUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.guest()),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
