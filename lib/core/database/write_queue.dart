import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/logging/app_logger.dart';

/// Serializes local write operations so large batches / rapid taps don't
/// contend for SQLite locks or flood the event loop.
@lazySingleton
class LocalWriteQueue {
  LocalWriteQueue(this._logger) {
    _init();
  }

  final AppLogger _logger;
  static const int _maxDepth = 100;

  int _pendingCount = 0;
  final _controller = StreamController<(_Job, Completer<void>)>();
  late final StreamSubscription _subscription;

  /// Returns the number of operations currently in the queue or being executed.
  int get pendingCount => _pendingCount;

  void _init() {
    _subscription = _controller.stream.listen((item) async {
      _subscription.pause();
      try {
        await item.$1();
        item.$2.complete();
      } catch (e, st) {
        _logger.error('LocalWriteQueue operation failed', e, st);
        item.$2.completeError(e, st);
      } finally {
        _pendingCount--;
        _subscription.resume();
      }
    });
  }

  /// Enqueues a write operation. Returns a Future that completes when the operation finishes.
  Future<void> enqueue(Future<void> Function() job) {
    if (_pendingCount >= _maxDepth) {
      _logger.warning(
        'LocalWriteQueue max depth reached ($_maxDepth). Skipping.',
      );
      return Future.value();
    }

    _pendingCount++;
    final completer = Completer<void>();
    _controller.add((job, completer));
    return completer.future;
  }

  @disposeMethod
  void close() {
    _subscription.cancel();
    _controller.close();
  }
}

typedef _Job = Future<void> Function();
