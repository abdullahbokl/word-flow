import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/word_repository.dart';

@lazySingleton
class DeleteWord {
  final WordRepository _repository;

  DeleteWord(this._repository);

  Future<Either<Failure, void>> call(String id, {String? userId}) {
    return _repository.deleteWord(id, userId: userId);
  }
}
