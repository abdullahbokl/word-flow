import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/word_repository.dart';

@lazySingleton
class AdoptGuestWords {
  final WordRepository _repository;

  AdoptGuestWords(this._repository);

  Future<Either<Failure, int>> call(String userId) {
    return _repository.adoptGuestWords(userId);
  }
}
