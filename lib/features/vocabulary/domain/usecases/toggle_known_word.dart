import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ToggleKnownWord {

  ToggleKnownWord(this._repository);
  final WordRepository _repository;

  Future<Either<Failure, void>> call(String text, {String? userId}) async {
    return await _repository.toggleKnown(text, userId: userId);
  }
}
