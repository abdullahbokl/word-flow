import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/history_detail.dart';
import '../repositories/history_repository.dart';

class GetHistoryDetail extends FutureUseCase<HistoryDetail, int> {
  const GetHistoryDetail(this._repository);

  final HistoryRepository _repository;

  Future<Either<Failure, HistoryDetail>> call(int id) =>
      _repository.getHistoryDetail(id);
}
