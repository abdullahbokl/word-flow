import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class SignOutAndClearLocal {
  SignOutAndClearLocal(this.authRepository, this.wordRepository);
  final AuthRepository authRepository;
  final WordRepository wordRepository;

  Future<Either<Failure, void>> call() async {
    final result = await authRepository.signOut();
    return result.fold(
      (failure) => Left(failure),
      (_) async {
        await wordRepository.clearLocalWords(userId: null);
        return const Right(null);
      },
    );
  }
}
