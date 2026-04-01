import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class GetKnownWords extends BaseUseCase<List<WordEntity>, UserIdParams> {
  GetKnownWords(this._repository);
  final WordRepository _repository;

  @override
  Future<Either<Failure, List<WordEntity>>> call(UserIdParams params) {
    return _repository.getKnownWords(userId: params.userId);
  }
}
