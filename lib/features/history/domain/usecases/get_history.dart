import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

class GetHistory extends FutureUseCase<List<HistoryItem>, NoParams> {
  const GetHistory(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, List<HistoryItem>>> call(NoParams params) => _repository.getHistory();
}
