import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:word_flow/core/config/env_config.dart';

enum ConnectivityStatus { online, offline }

@lazySingleton
class ConnectivityMonitor {
  ConnectivityMonitor() : _checker = InternetConnection() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _checker;
  
  ConnectivityStatus? _lastStatus;
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetSubscription;
  Timer? _debounceTimer;

  static const Duration reconnectDebounce = Duration(seconds: 3);

  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  void _init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) => _evaluateConnectivity());
    _internetSubscription = _checker.onStatusChange.listen((_) => _evaluateConnectivity());

    // Initial check
    _evaluateConnectivity();
  }

  Future<void> _evaluateConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final hasInterface = !results.contains(ConnectivityResult.none);
    final hasInternet = await _checker.hasInternetAccess;

    final newStatus = (hasInterface && hasInternet) 
        ? ConnectivityStatus.online 
        : ConnectivityStatus.offline;

    if (newStatus == ConnectivityStatus.offline) {
      _debounceTimer?.cancel();
      _emitIfChanged(ConnectivityStatus.offline);
    } else {
      // If we were offline or initial, and now interface is up, debounce the "online" event
      if (_lastStatus != ConnectivityStatus.online && !(_debounceTimer?.isActive ?? false)) {
        _debounceTimer = Timer(reconnectDebounce, () async {
          if (await _checker.hasInternetAccess) {
            _emitIfChanged(ConnectivityStatus.online);
          }
        });
      }
    }
  }

  void _emitIfChanged(ConnectivityStatus status) {
    if (_lastStatus != status) {
      _lastStatus = status;
      _controller.add(status);
    }
  }

  /// Verifies actual reachability to the Supabase health endpoint.
  /// Useful for detecting captive portals or domain-specific blocks.
  Future<bool> checkReachability() async {
    if (!EnvConfig.isConfigured) return false;
    
    try {
      final response = await http.head(
        Uri.parse('${EnvConfig.supabaseUrl}/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the device has a network interface and internet access.
  /// Uses cached status from InternetConnectionCheckerPlus for speed.
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) return false;
    return await _checker.hasInternetAccess;
  }

  @disposeMethod
  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _controller.close();
  }
}
