import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/repositories/word_repository.dart';

@lazySingleton
class GetGuestWordsCount {

  GetGuestWordsCount(this._repository);
  final WordRepository _repository;

  Future<Either<Failure, int>> call() {
    return _repository.getGuestWordsCount();
  }
}
