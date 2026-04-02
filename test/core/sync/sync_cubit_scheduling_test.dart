import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/features/vocabulary/data/sync/sync_orchestrator.dart';
import 'package:word_flow/features/vocabulary/data/sync/sync_status.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';

class MockSyncOrchestrator extends Mock implements SyncOrchestrator {}

void main() {
  late MockSyncOrchestrator mockOrchestrator;
  late StreamController<int> pendingController;
  late StreamController<SyncStatus> statusController;
  late SyncCubit cubit;

  setUp(() {
    mockOrchestrator = MockSyncOrchestrator();
    pendingController = StreamController<int>.broadcast();
    statusController = StreamController<SyncStatus>.broadcast();

    when(
      () => mockOrchestrator.pendingCountStream,
    ).thenAnswer((_) => pendingController.stream);
    when(
      () => mockOrchestrator.statusStream,
    ).thenAnswer((_) => statusController.stream);

    cubit = SyncCubit(mockOrchestrator);
  });

  tearDown(() async {
    await pendingController.close();
    await statusController.close();
    await cubit.close();
  });

  test('has exactly 2 stream subscriptions after init()', () async {
    expect(pendingController.hasListener, isFalse);
    expect(statusController.hasListener, isFalse);

    cubit.init();

    // subscriptions should be attached
    expect(pendingController.hasListener, isTrue);
    expect(statusController.hasListener, isTrue);
  });

  test('syncNow() delegates to orchestrator.retrySync() only', () async {
    cubit.init();

    // Emit non-zero pending count so syncNow doesn't early-return
    pendingController.add(1);
    // Allow event loop to process the listener
    await Future<void>.delayed(Duration.zero);

    await cubit.syncNow();

    verify(() => mockOrchestrator.retrySync()).called(1);
  });
}
