import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/entities/auth_state_change.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._supabase);
  final supabase.SupabaseClient _supabase;

  @override
  Stream<AuthStateChange> get authStateStream =>
      _supabase.auth.onAuthStateChange.map((data) {
        switch (data.event) {
          case supabase.AuthChangeEvent.signedIn:
            return AuthStateChange.signedIn;
          case supabase.AuthChangeEvent.signedOut:
            return AuthStateChange.signedOut;
          case supabase.AuthChangeEvent.tokenRefreshed:
            return AuthStateChange.tokenRefreshed;
          case supabase.AuthChangeEvent.userUpdated:
            return AuthStateChange.userUpdated;
          default:
            return AuthStateChange.unknown;
        }
      });

  @override
  AuthUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AuthUser(id: user.id, email: user.email ?? '');
  }

  @override
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return const Left(AuthFailure('User not found'));
      return Right(AuthUser(id: user.id, email: user.email ?? ''));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return const Left(AuthFailure('Sign up failed'));
      return Right(AuthUser(id: user.id, email: user.email ?? ''));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
