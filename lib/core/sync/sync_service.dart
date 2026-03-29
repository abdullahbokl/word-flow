import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';
import 'package:word_flow/core/sync/connectivity_monitor.dart';

@lazySingleton
class SyncService {

  SyncService(this._syncRepository, this._connectivityMonitor) {
    _init();
  }
  final SyncRepository _syncRepository;
  final ConnectivityMonitor _connectivityMonitor;
  Timer? _syncTimer;

  void _init() {
    _connectivityMonitor.statusStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        syncNow();
      }
    });

   
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) => syncNow());
  }

  Future<void> syncNow() async {
    final isOnline = await _connectivityMonitor.isOnline;
    if (!isOnline) return;

    await _syncRepository.syncPendingWords();
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
