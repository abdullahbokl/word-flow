import 'dart:async';
import 'dart:isolate';

class IsolateManager {
  factory IsolateManager() => _instance;
  IsolateManager._internal();
  static final IsolateManager _instance = IsolateManager._internal();

  final Map<String, Isolate> _isolates = {};
  final Map<String, ReceivePort> _receivePorts = {};
  final Map<String, Completer<dynamic>> _completers = {};

  /// Execute a heavy computation in an isolate
  Future<T> compute<T, P>(
    String taskId,
    Future<T> Function(P) function,
    P params,
  ) async {
    // Check if task already running
    if (_completers.containsKey(taskId)) {
      return _completers[taskId]!.future as Future<T>;
    }

    final completer = Completer<T>();
    _completers[taskId] = completer;

    final receivePort = ReceivePort();
    _receivePorts[taskId] = receivePort;

    try {
      final isolate = await Isolate.spawn(
        _isolateEntry,
        _IsolateMessage(receivePort.sendPort, function, params),
      );
      _isolates[taskId] = isolate;

      receivePort.listen((message) {
        if (message is T) {
          completer.complete(message);
          _cleanup(taskId);
        } else if (message is Error) {
          completer.completeError(message);
          _cleanup(taskId);
        } else if (message is _IsolateError) {
          completer.completeError(message.error);
          _cleanup(taskId);
        }
      });

      // Timeout after 30 seconds
      Timer(const Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          completer
              .completeError(TimeoutException('Isolate computation timeout'));
          _cleanup(taskId);
        }
      });

      return completer.future;
    } catch (e) {
      _cleanup(taskId);
      rethrow;
    }
  }

  /// Cancel a running isolate task
  void cancel(String taskId) {
    _isolates[taskId]?.kill(priority: Isolate.immediate);
    _cleanup(taskId);
  }

  /// Check if a task is running
  bool isRunning(String taskId) {
    return _completers.containsKey(taskId) && !_completers[taskId]!.isCompleted;
  }

  /// Cleanup resources
  void _cleanup(String taskId) {
    _isolates[taskId]?.kill();
    _receivePorts[taskId]?.close();
    _isolates.remove(taskId);
    _receivePorts.remove(taskId);
    _completers.remove(taskId);
  }

  /// Dispose all isolates
  void dispose() {
    for (final taskId in _isolates.keys.toList()) {
      _cleanup(taskId);
    }
  }

  /// Entry point for isolate execution
  static void _isolateEntry(_IsolateMessage message) async {
    try {
      final result = await message.function(message.params);
      message.sendPort.send(result);
    } catch (e, stackTrace) {
      message.sendPort.send(_IsolateError(e.toString(), stackTrace.toString()));
    }
  }
}

/// Message class for isolate communication
class _IsolateMessage {
  _IsolateMessage(this.sendPort, this.function, this.params);
  final SendPort sendPort;
  final Function function;
  final dynamic params;
}

/// Error wrapper for isolate communication
class _IsolateError {
  _IsolateError(this.error, this.stackTrace);
  final String error;
  final String stackTrace;
}
