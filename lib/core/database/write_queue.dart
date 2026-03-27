import 'dart:async';

import 'package:injectable/injectable.dart';

/// Serializes local write operations so large batches / rapid taps don't
/// contend for SQLite locks or flood the event loop.
@lazySingleton
class LocalWriteQueue {
  Future<void> _tail = Future<void>.value();

  Future<T> enqueue<T>(Future<T> Function() job) {
    final completer = Completer<T>();

    _tail = _tail.then((_) async {
      try {
        final result = await job();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });

    return completer.future;
  }
}

