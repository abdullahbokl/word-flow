import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/sync_pending_words.dart';
import '../../domain/usecases/watch_pending_count.dart';
import 'sync_state.dart';

@injectable
class SyncCubit extends Cubit<SyncState> {
  final WatchPendingCount _watchPendingCount;
  final SyncPendingWords _syncPendingWords;
  StreamSubscription<int>? _pendingSub;

  SyncCubit(this._watchPendingCount, this._syncPendingWords)
      : super(const SyncState.idle(pendingCount: 0)) {
    _startWatching();
  }

  void _startWatching() {
    _pendingSub?.cancel();
    _pendingSub = _watchPendingCount().listen((count) {
      emit(SyncState.idle(
        pendingCount: count,
        lastSyncTime: state.maybeMap(idle: (s) => s.lastSyncTime, orElse: () => null),
      ));
    });
  }

  Future<void> syncNow() async {
    emit(SyncState.syncing(pendingCount: state.pendingCount));
    final result = await _syncPendingWords();
    result.fold(
      (failure) => emit(SyncState.error(
        pendingCount: state.pendingCount,
        message: failure.message,
      )),
      (_) => emit(SyncState.idle(
        pendingCount: 0,
        lastSyncTime: DateTime.now(),
      )),
    );
  }

  @override
  Future<void> close() {
    _pendingSub?.cancel();
    return super.close();
  }
}
