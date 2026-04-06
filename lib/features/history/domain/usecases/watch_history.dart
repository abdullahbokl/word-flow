import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

class WatchHistory extends StreamUseCase<List<HistoryItem>, NoParams> {
  const WatchHistory(this._repository);
  final HistoryRepository _repository;

  Stream<Either<Failure, List<HistoryItem>>> call() => _repository.watchHistory();
}
