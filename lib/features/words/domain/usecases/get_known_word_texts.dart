import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/word_repository.dart';

@lazySingleton
class GetKnownWordTexts {
  final WordRepository _repository;

  GetKnownWordTexts(this._repository);

  Future<Either<Failure, List<String>>> call({String? userId}) {
    return _repository.getKnownWordTexts(userId: userId);
  }
}
