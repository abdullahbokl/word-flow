import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/features/vocabulary/data/sync/sync_operation.dart';

void main() {
  test("SyncOperation.fromString('upsert') == SyncOperation.upsert", () {
    expect(SyncOperation.fromString('upsert'), SyncOperation.upsert);
  });

  test("SyncOperation.fromString('delete') == SyncOperation.delete", () {
    expect(SyncOperation.fromString('delete'), SyncOperation.delete);
  });

  test("SyncOperation.fromString('unknown') == null (no throw)", () {
    expect(SyncOperation.fromString('unknown'), isNull);
  });

  test("SyncOperation.fromString('') == null (no throw)", () {
    expect(SyncOperation.fromString(''), isNull);
  });
}
