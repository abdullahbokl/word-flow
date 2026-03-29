import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class GetKnownWordTexts extends BaseUseCase<List<String>, UserIdParams> {
  GetKnownWordTexts(this._repository);
  final WordRepository _repository;

  @override
  Future<Either<Failure, List<String>>> call(UserIdParams params) {
    return _repository.getKnownWordTexts(userId: params.userId);
  }
}
