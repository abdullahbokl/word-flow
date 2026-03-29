import 'package:dartz/dartz.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Stream<UserEntity?> get userStream;
}
