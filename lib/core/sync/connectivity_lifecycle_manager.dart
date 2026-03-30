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
    if (state == AppLifecycleState.detached) {
      _monitor.dispose();
      stop();
    }
  }

  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
  }
}
