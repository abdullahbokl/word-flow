import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/history/domain/repositories/history_repository.dart';

class DeleteHistoryItemParams {
  const DeleteHistoryItemParams({required this.id, required this.deleteUniqueWords});
  final int id;
  final bool deleteUniqueWords;
}

class DeleteHistoryItem extends FutureUseCase<void, DeleteHistoryItemParams> {
  const DeleteHistoryItem(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteHistoryItemParams params) =>
      _repository.deleteHistoryItem(params.id, deleteUniqueWords: params.deleteUniqueWords);
}
