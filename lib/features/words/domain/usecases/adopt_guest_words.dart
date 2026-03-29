import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/repositories/word_repository.dart';

@lazySingleton
class AdoptGuestWords {

  AdoptGuestWords(this._repository);
  final WordRepository _repository;

  Future<Either<Failure, int>> call(String userId) {
    return _repository.adoptGuestWords(userId);
  }
}
