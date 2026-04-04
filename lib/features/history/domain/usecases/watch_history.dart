import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

class WatchHistory {
  const WatchHistory(this._repository);
  final HistoryRepository _repository;

  Stream<Either<Failure, List<HistoryItem>>> call() => _repository.watchHistory();
}
