import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/history/domain/entities/history_detail.dart';
import 'package:wordflow/features/history/domain/entities/history_item.dart';

abstract class HistoryRepository {
  /// Fetches a list of history items, optionally paged.
  Future<Either<Failure, List<HistoryItem>>> getHistory(
      {int? limit, int? offset});

  /// Watches a list of history items, optionally paged.
  Stream<Either<Failure, List<HistoryItem>>> watchHistory(
      {int? limit, int? offset});

  /// Deletes a history item and optionally its associated unique words.
  Future<Either<Failure, void>> deleteHistoryItem(int id,
      {bool deleteUniqueWords = false});

  /// Fetches details for a specific history item.
  Future<Either<Failure, HistoryDetail>> getHistoryDetail(int id);

  /// Watches details for a specific history item.
  Stream<Either<Failure, HistoryDetail>> watchHistoryDetail(int id);
}
