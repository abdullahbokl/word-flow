import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/history/domain/entities/history_item.dart';
import 'package:lexitrack/features/history/domain/repositories/history_repository.dart';

class HistoryPaginationParams {
  const HistoryPaginationParams({this.limit, this.offset});
  final int? limit;
  final int? offset;
}

class WatchHistory extends StreamUseCase<List<HistoryItem>, HistoryPaginationParams> {
  const WatchHistory(this._repository);
  final HistoryRepository _repository;

  @override
  Stream<Either<Failure, List<HistoryItem>>> call(HistoryPaginationParams params) =>
      _repository.watchHistory(limit: params.limit, offset: params.offset);
}
