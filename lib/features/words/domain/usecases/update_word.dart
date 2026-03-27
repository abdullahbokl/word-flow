import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/word.dart';
import '../repositories/word_repository.dart';

@lazySingleton
class UpdateWord {
  final WordRepository _repository;

  UpdateWord(this._repository);

  Future<Either<Failure, void>> call(Word word) {
    return _repository.updateWord(word);
  }
}
