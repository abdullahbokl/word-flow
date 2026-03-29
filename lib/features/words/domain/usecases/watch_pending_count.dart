import 'package:injectable/injectable.dart';
import 'package:word_flow/features/words/domain/repositories/sync_repository.dart';

@lazySingleton
class WatchPendingCount {

  WatchPendingCount(this._repository);
  final SyncRepository _repository;

  Stream<int> call() {
    return _repository.watchPendingCount();
  }
}
