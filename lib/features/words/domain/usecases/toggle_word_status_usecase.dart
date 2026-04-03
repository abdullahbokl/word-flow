import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/words/repositories/word_repository.dart';

@injectable
class ToggleWordStatusUseCase implements UseCase<void, String> {
  ToggleWordStatusUseCase(this._repository);

  final WordRepository _repository;

  @override
  Future<Either<Failure, void>> call(String wordText) async {
    return _repository.toggleKnown(wordText);
  }
}
