enum SyncOperation {
  upsert,
  delete;

  String get value => name;

  static SyncOperation fromString(String s) => SyncOperation.values.firstWhere(
    (e) => e.value == s,
    orElse: () => throw ArgumentError('Unknown sync operation: $s'),
  );
}
