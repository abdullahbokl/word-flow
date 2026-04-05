import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

class GetHistory {
  const GetHistory(this._repository);

  final HistoryRepository _repository;

  Future<Either<Failure, List<HistoryItem>>> call() =>
      _repository.getHistory();
}
