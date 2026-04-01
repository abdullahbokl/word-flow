import 'package:collection/collection.dart';

enum SyncOperation {
  upsert,
  delete;

  String get value => name;

  static SyncOperation? fromString(String s) => SyncOperation.values.firstWhereOrNull(
    (e) => e.value == s,
  );
}
