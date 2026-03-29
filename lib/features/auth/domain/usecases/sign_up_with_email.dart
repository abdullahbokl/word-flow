import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/domain/entities/user_entity.dart';

@lazySingleton
class SignUpWithEmail {

  SignUpWithEmail(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.signUpWithEmail(
      email: email,
      password: password,
    );
  }
}
