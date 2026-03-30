import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:word_flow/core/errors/exceptions.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/errors/error_mapper.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/entities/auth_state_change.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/data/datasources/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._supabase, this._remoteSource, this._logger);
  final supabase.SupabaseClient _supabase;
  final AuthRemoteSource _remoteSource;
  final AppLogger _logger;

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
      final user = await _remoteSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Auth error occurred.'));
    } catch (e, stackTrace) {
      return Left(ErrorMapper.mapException(e, stackTrace, _logger) as AuthFailure);
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmail(String email, String password) async {
    try {
      final user = await _remoteSource.signUpWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Auth error occurred.'));
    } catch (e, stackTrace) {
      return Left(ErrorMapper.mapException(e, stackTrace, _logger) as AuthFailure);
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Auth error occurred.'));
    } catch (e, stackTrace) {
      return Left(ErrorMapper.mapException(e, stackTrace, _logger) as AuthFailure);
    }
  }
}
