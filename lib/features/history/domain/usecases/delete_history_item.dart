import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/history_repository.dart';

class DeleteHistoryItem extends FutureUseCase<void, int> {
  const DeleteHistoryItem(this._repository);

  final HistoryRepository _repository;

  Future<Either<Failure, void>> call(int id, {bool deleteUniqueWords = false}) =>
      _repository.deleteHistoryItem(id, deleteUniqueWords: deleteUniqueWords);
}
