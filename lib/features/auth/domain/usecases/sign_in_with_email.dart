import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

@lazySingleton
class SignInWithEmail {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
