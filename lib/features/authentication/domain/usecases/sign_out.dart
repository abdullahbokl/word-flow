import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/authentication/domain/repositories/auth_repository.dart';

@lazySingleton
class SignOut {

  SignOut(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
