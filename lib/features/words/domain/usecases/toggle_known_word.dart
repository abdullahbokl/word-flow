import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/word_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ToggleKnownWord {
  final WordRepository _repository;

  ToggleKnownWord(this._repository);

  Future<Either<Failure, void>> call(String text, {String? userId}) async {
    return await _repository.toggleKnown(text, userId: userId);
  }
}
