import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';

@lazySingleton
class SignInWithEmailUseCase {
  SignInWithEmailUseCase(this.authRepository);
  final AuthRepository authRepository;

  Future<Either<Failure, AuthUser>> call(String email, String password) async {
    return await authRepository.signInWithEmail(email, password);
  }
}

@lazySingleton
class SignUpWithEmailUseCase {
  SignUpWithEmailUseCase(this.authRepository);
  final AuthRepository authRepository;

  Future<Either<Failure, AuthUser>> call(String email, String password) async {
    return await authRepository.signUpWithEmail(email, password);
  }
}
