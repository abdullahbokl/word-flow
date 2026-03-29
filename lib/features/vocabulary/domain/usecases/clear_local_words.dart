import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class ClearLocalWords extends BaseUseCase<void, ClearLocalWordsParams> {
  ClearLocalWords(this._repository);
  final WordRepository _repository;

  @override
  Future<Either<Failure, void>> call(ClearLocalWordsParams params) {
    return _repository.clearLocalWords(userId: params.userId);
  }
}

class ClearLocalWordsParams extends Equatable {
  const ClearLocalWordsParams({this.userId});
  final String? userId;

  @override
  List<Object?> get props => [userId];
}
