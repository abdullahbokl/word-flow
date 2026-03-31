import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/validators/auth_validators.dart';

@lazySingleton
class SignInWithEmailUseCase {
  SignInWithEmailUseCase(this.authRepository);
  final AuthRepository authRepository;

  Future<Either<Failure, AuthUser>> call(String email, String password) async {
    final emailRes = EmailValidator.validate(email);
    if (emailRes.isLeft())
      return Left(emailRes.fold((l) => l, (r) => throw UnimplementedError()));

    final passRes = PasswordValidator.validate(password);
    if (passRes.isLeft())
      return Left(passRes.fold((l) => l, (r) => throw UnimplementedError()));

    return await authRepository.signInWithEmail(email, password);
  }
}

@lazySingleton
class SignUpWithEmailUseCase {
  SignUpWithEmailUseCase(this.authRepository);
  final AuthRepository authRepository;

  Future<Either<Failure, AuthUser>> call(String email, String password) async {
    final emailRes = EmailValidator.validate(email);
    if (emailRes.isLeft())
      return Left(emailRes.fold((l) => l, (r) => throw UnimplementedError()));

    final passRes = PasswordValidator.validate(password);
    if (passRes.isLeft())
      return Left(passRes.fold((l) => l, (r) => throw UnimplementedError()));

    return await authRepository.signUpWithEmail(email, password);
  }
}
