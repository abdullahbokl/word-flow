import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/entities/auth_state_change.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';

class GuestAuthRepository implements AuthRepository {
  @override
  Stream<AuthStateChange> get authStateStream => Stream.empty();

  @override
  AuthUser? get currentUser => null;

  @override
  String? get currentUserId => null;

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail(String email, String password) async {
    return const Left(AuthFailure('Remote authentication is disabled. Check your environment configuration.'));
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmail(String email, String password) async {
    return const Left(AuthFailure('Remote authentication is disabled. Check your environment configuration.'));
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return const Right(null);
  }
}
