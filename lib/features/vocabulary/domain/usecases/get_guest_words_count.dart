import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class GetGuestWordsCount extends BaseUseCase<int, NoParams> {
  GetGuestWordsCount(this._repository);
  final WordRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _repository.getGuestWordsCount();
  }
}
