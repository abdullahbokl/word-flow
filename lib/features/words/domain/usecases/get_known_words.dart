import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/word.dart';
import '../repositories/word_repository.dart';

@lazySingleton
class GetKnownWords {
  final WordRepository _repository;

  GetKnownWords(this._repository);

  Future<Either<Failure, List<WordEntity>>> call({String? userId}) {
    return _repository.getKnownWords(userId: userId);
  }
}
