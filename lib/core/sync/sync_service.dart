import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../features/words/domain/repositories/sync_repository.dart';
import 'connectivity_monitor.dart';

@lazySingleton
class SyncService {
  final SyncRepository _syncRepository;
  final ConnectivityMonitor _connectivityMonitor;
  Timer? _syncTimer;

  SyncService(this._syncRepository, this._connectivityMonitor) {
    _init();
  }

  void _init() {
    _connectivityMonitor.statusStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        syncNow();
      }
    });

    // Perodic sync every 5 minutes as a fallback
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
