import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class UpdateWord extends BaseUseCase<void, WordEntity> {
  UpdateWord(this._repository);
  final WordRepository _repository;

  @override
  Future<Either<Failure, void>> call(WordEntity word) {
    return _repository.updateWord(word);
  }
}
