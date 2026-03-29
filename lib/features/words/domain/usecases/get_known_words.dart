import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/entities/word.dart';
import 'package:word_flow/features/words/domain/repositories/word_repository.dart';

@lazySingleton
class GetKnownWords {

  GetKnownWords(this._repository);
  final WordRepository _repository;

  Future<Either<Failure, List<WordEntity>>> call({String? userId}) {
    return _repository.getKnownWords(userId: userId);
  }
}
