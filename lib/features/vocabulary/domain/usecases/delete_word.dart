import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

@lazySingleton
class DeleteWord extends BaseUseCase<void, DeleteWordParams> {
  DeleteWord(this._repository);
  final WordRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteWordParams params) {
    return _repository.deleteWord(params.id, userId: params.userId);
  }
}

class DeleteWordParams extends Equatable {
  const DeleteWordParams({required this.id, this.userId});
  final String id;
  final String? userId;

  @override
  List<Object?> get props => [id, userId];
}
