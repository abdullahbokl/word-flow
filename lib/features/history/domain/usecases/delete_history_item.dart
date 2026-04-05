import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/history_repository.dart';

class DeleteHistoryItem {
  const DeleteHistoryItem(this._repository);

  final HistoryRepository _repository;

  Future<Either<Failure, void>> call(int id, {bool deleteUniqueWords = false}) =>
      _repository.deleteHistoryItem(id, deleteUniqueWords: deleteUniqueWords);
}
