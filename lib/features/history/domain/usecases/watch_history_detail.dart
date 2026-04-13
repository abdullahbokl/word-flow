import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/history/domain/entities/history_detail.dart';
import 'package:wordflow/features/history/domain/repositories/history_repository.dart';

class WatchHistoryDetail extends StreamUseCase<HistoryDetail, int> {
  const WatchHistoryDetail(this._repository);

  final HistoryRepository _repository;

  @override
  Stream<Either<Failure, HistoryDetail>> call(int id) =>
      _repository.watchHistoryDetail(id);
}
