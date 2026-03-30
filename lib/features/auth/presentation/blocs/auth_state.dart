import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(AuthUser user) = AuthAuthenticated;
  const factory AuthState.pendingMerge(AuthUser user, int guestWordCount) =
      AuthPendingMerge;
  const factory AuthState.guest() = AuthGuest;
  const factory AuthState.passwordRecovery() = AuthPasswordRecovery;
  const factory AuthState.error(String message) = AuthError;
  const factory AuthState.rateLimited(Duration cooldown) = AuthRateLimited;
}
