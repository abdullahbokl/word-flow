import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource remoteSource;

  AuthRepositoryImpl(this.remoteSource);

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteSource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Auth error occurred.'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteSource.signUpWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Auth error occurred.'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Auth error occurred.'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get userStream => remoteSource.userStream;
}
