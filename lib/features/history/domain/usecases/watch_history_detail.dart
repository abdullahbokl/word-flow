import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/history/domain/entities/history_detail.dart';
import 'package:lexitrack/features/history/domain/repositories/history_repository.dart';

class WatchHistoryDetail extends StreamUseCase<HistoryDetail, int> {
  const WatchHistoryDetail(this._repository);

  final HistoryRepository _repository;

  @override
  Stream<Either<Failure, HistoryDetail>> call(int id) =>
      _repository.watchHistoryDetail(id);
}
