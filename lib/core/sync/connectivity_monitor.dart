import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

enum ConnectivityStatus { online, offline }

@lazySingleton
class ConnectivityMonitor {

  ConnectivityMonitor() {
    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  Future<void> _updateStatus(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none)) {
      _controller.add(ConnectivityStatus.offline);
    } else {
      _controller.add(ConnectivityStatus.online);
    }
  }

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
