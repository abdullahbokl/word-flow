import 'package:injectable/injectable.dart';
import '../repositories/sync_repository.dart';

@lazySingleton
class WatchPendingCount {
  final SyncRepository _repository;

  WatchPendingCount(this._repository);

  Stream<int> call() {
    return _repository.watchPendingCount();
  }
}
