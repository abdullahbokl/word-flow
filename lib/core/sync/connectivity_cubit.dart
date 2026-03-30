import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/sync/connectivity_monitor.dart';

enum ConnectivityState { initial, online, offline }

@lazySingleton
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit(this._monitor) : super(ConnectivityState.initial) {
    _init();
  }

  final ConnectivityMonitor _monitor;
  StreamSubscription? _subscription;

  void _init() {
    _subscription = _monitor.statusStream.listen((status) {
      emit(status == ConnectivityStatus.online
          ? ConnectivityState.online
          : ConnectivityState.offline);
    });
    
    // Initial state check
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final isOnline = await _monitor.isOnline;
    if (!isClosed) {
      emit(isOnline ? ConnectivityState.online : ConnectivityState.offline);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
