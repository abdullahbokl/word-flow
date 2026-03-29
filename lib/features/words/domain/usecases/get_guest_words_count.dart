import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/word_repository.dart';

@lazySingleton
class GetGuestWordsCount {
  final WordRepository _repository;

  GetGuestWordsCount(this._repository);

  Future<Either<Failure, int>> call() {
    return _repository.getGuestWordsCount();
  }
}
