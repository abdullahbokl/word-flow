import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/sync/connectivity_monitor.dart';

/// Ensures lazy singleton monitor resources are released when app detaches.
@lazySingleton
class ConnectivityLifecycleManager with WidgetsBindingObserver {
  ConnectivityLifecycleManager(this._monitor);

  final ConnectivityMonitor _monitor;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App moved to background (iOS: suspended, Android: background)
        // Cancel debounce timers to stop background network probes.
        _monitor.pauseConnectivityChecks();
        break;
      case AppLifecycleState.resumed:
        // App returned to foreground — re-evaluate connectivity.
        _monitor.resumeConnectivityChecks();
        break;
      case AppLifecycleState.detached:
        _monitor.dispose();
        stop();
        break;
      default:
        break;
    }
  }

  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
  }
}
