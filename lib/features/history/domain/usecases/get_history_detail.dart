import 'package:fpdart/fpdart.dart';

import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/usecase/usecase.dart';
import 'package:wordflow/features/history/domain/entities/history_detail.dart';
import 'package:wordflow/features/history/domain/repositories/history_repository.dart';

class GetHistoryDetail extends FutureUseCase<HistoryDetail, int> {
  const GetHistoryDetail(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, HistoryDetail>> call(int id) =>
      _repository.getHistoryDetail(id);
}
