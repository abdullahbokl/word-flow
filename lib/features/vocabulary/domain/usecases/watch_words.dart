import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class WatchWords extends BaseStreamUseCase<List<WordEntity>, UserIdParams> {
  WatchWords(this._repository);
  final WordRepository _repository;

  @override
  Stream<Either<Failure, List<WordEntity>>> call(UserIdParams params) {
    return _repository
        .watchWords(userId: params.userId)
        .map((words) => Right(words));
  }
}
