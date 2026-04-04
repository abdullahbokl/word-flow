import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/history_detail.dart';
import '../entities/history_item.dart';

abstract interface class HistoryRepository {
  TaskEither<Failure, List<HistoryItem>> getHistory();
  Stream<Either<Failure, List<HistoryItem>>> watchHistory();
  TaskEither<Failure, Unit> deleteHistoryItem(int id, {bool deleteUniqueWords = false});
  TaskEither<Failure, HistoryDetail> getHistoryDetail(int id);
  Stream<Either<Failure, HistoryDetail>> watchHistoryDetail(int id);
}
