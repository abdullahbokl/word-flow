import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum ConnectivityStatus { online, offline }

@lazySingleton
class ConnectivityMonitor {
  ConnectivityMonitor() : _checker = InternetConnection() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _checker;

  ConnectivityStatus? _lastStatus;
  bool _isEvaluating = false;
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetSubscription;
  Timer? _debounceTimer;
  bool _isDisposed = false;

  static const Duration reconnectDebounce = Duration(seconds: 3);

  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  void _init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (_) => _evaluateConnectivity(),
    );
    _internetSubscription = _checker.onStatusChange.listen(
      (_) => _evaluateConnectivity(),
    );

    // Initial check
    _evaluateConnectivity();
  }
  Future<void> _evaluateConnectivity() async {
    if (_isDisposed) return;
    if (_isEvaluating) return;
    _isEvaluating = true;
    try {
      final results = await _connectivity.checkConnectivity();
      if (_isDisposed) return;

      final hasInterface = !results.contains(ConnectivityResult.none);
      final hasInternet = await _checker.hasInternetAccess;
      if (_isDisposed) return;

      final newStatus = (hasInterface && hasInternet)
          ? ConnectivityStatus.online
          : ConnectivityStatus.offline;

      if (newStatus == ConnectivityStatus.offline) {
        _debounceTimer?.cancel();
        _emitIfChanged(ConnectivityStatus.offline);
      } else {
        if (_lastStatus != ConnectivityStatus.online &&
            !(_debounceTimer?.isActive ?? false)) {
          _debounceTimer = Timer(reconnectDebounce, () async {
            if (await _checker.hasInternetAccess) {
              _emitIfChanged(ConnectivityStatus.online);
            }
          });
        }
      }
    } finally {
      _isEvaluating = false;
    }
  }

  void _emitIfChanged(ConnectivityStatus status) {
    if (_isDisposed) return;
    if (_lastStatus != status) {
      _lastStatus = status;
      _controller.add(status);
    }
  }
  Future<bool> get isOnline async {
    if (_isDisposed) return false;
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) return false;
    return await _checker.hasInternetAccess;
  }

  /// Pause ongoing connectivity checks (cancel debounce timer) — useful when
  /// app is backgrounded on iOS to conserve resources and avoid background
  /// network probes.
  void pauseConnectivityChecks() {
    _debounceTimer?.cancel();
  }

  /// Resume connectivity evaluation when app returns to foreground.
  void resumeConnectivityChecks() {
    if (!_isDisposed) _evaluateConnectivity();
  }

  @disposeMethod
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _controller.close();
  }
}
