import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/error/failures.dart';
import 'package:word_flow/features/words/domain/repositories/word_repository.dart';

@lazySingleton
class GetKnownWordTexts {

  GetKnownWordTexts(this._repository);
  final WordRepository _repository;

  Future<Either<Failure, List<String>>> call({String? userId}) {
    return _repository.getKnownWordTexts(userId: userId);
  }
}
