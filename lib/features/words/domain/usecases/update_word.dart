import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/entities/word.dart';
import 'package:word_flow/features/words/domain/repositories/word_repository.dart';

@lazySingleton
class UpdateWord {

  UpdateWord(this._repository);
  final WordRepository _repository;

  Future<Either<Failure, void>> call(WordEntity word) {
    return _repository.updateWord(word);
  }
}
