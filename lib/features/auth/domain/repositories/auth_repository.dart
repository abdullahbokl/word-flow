import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/entities/auth_state_change.dart';

abstract class AuthRepository {
  Stream<AuthStateChange> get authStateStream;
  AuthUser? get currentUser;
  String? get currentUserId;
  Future<Either<Failure, AuthUser>> signInWithEmail(String email, String password);
  Future<Either<Failure, AuthUser>> signUpWithEmail(String email, String password);
  Future<Either<Failure, void>> signOut();
}
