import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/history_detail.dart';
import '../repositories/history_repository.dart';

class WatchHistoryDetail {
  WatchHistoryDetail(this.repository);

  final HistoryRepository repository;

  Stream<Either<Failure, HistoryDetail>> call(int id) {
    return repository.watchHistoryDetail(id);
  }
}
