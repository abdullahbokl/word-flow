import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class SignOut {

  SignOut(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
