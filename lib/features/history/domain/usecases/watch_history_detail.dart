import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/history_detail.dart';
import '../repositories/history_repository.dart';

class WatchHistoryDetail {
  const WatchHistoryDetail(this._repository);

  final HistoryRepository _repository;

  Stream<Either<Failure, HistoryDetail>> call(int id) =>
      _repository.watchHistoryDetail(id);
}
