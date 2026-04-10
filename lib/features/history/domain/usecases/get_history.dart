import 'package:fpdart/fpdart.dart';

import 'package:lexitrack/core/error/failures.dart';
import 'package:lexitrack/core/usecase/usecase.dart';
import 'package:lexitrack/features/history/domain/entities/history_item.dart';
import 'package:lexitrack/features/history/domain/repositories/history_repository.dart';

class GetHistory extends FutureUseCase<List<HistoryItem>, NoParams> {
  const GetHistory(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, List<HistoryItem>>> call(NoParams params) => _repository.getHistory();
}
