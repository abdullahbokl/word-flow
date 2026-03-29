import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/word_repository.dart';

@lazySingleton
class ClearLocalWords {
  final WordRepository _repository;

  ClearLocalWords(this._repository);

  Future<Either<Failure, void>> call({String? userId}) {
    return _repository.clearLocalWords(userId: userId);
  }
}
