import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/history_item.dart';
import '../entities/history_detail.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryItem>>> getHistory();
  Stream<Either<Failure, List<HistoryItem>>> watchHistory();
  Future<Either<Failure, void>> deleteHistoryItem(int id, {bool deleteUniqueWords = false});
  Future<Either<Failure, HistoryDetail>> getHistoryDetail(int id);
  Stream<Either<Failure, HistoryDetail>> watchHistoryDetail(int id);
}
