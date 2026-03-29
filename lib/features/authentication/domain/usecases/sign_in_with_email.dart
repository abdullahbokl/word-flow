import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/authentication/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/authentication/domain/entities/user_entity.dart';

@lazySingleton
class SignInWithEmail {

  SignInWithEmail(this.repository);
  final AuthRepository repository;

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
