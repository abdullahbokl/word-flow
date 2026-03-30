import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(AuthUser user) = _Authenticated;
  const factory AuthState.guest() = _Guest;
  const factory AuthState.error(String message) = _Error;
}
