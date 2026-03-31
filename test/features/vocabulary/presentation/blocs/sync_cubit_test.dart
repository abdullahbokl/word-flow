import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/sync/sync_orchestrator.dart';
import 'package:word_flow/core/sync/sync_status.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';

class MockSyncOrchestrator extends Mock implements SyncOrchestrator {}

void main() {
  late SyncCubit cubit;
  late MockSyncOrchestrator mockSyncOrchestrator;

  setUp(() {
    mockSyncOrchestrator = MockSyncOrchestrator();

    when(
      () => mockSyncOrchestrator.pendingCountStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockSyncOrchestrator.statusStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockSyncOrchestrator.retrySync()).thenReturn(null);

    cubit = SyncCubit(mockSyncOrchestrator);
  });

  group('SyncCubit - syncNow delegation', () {
    test(
      'calls SyncOrchestrator.retrySync when pendingCount > 0',
      () async {
        // Create fresh mock for this specific test
        final testMock = MockSyncOrchestrator();
        
        // Set up streams to emit values
        when(() => testMock.pendingCountStream).thenAnswer(
          (_) => Stream<int>.fromIterable([0, 1, 2]),
        );
        when(() => testMock.statusStream).thenAnswer(
          (_) => const Stream.empty(),
        );
        when(() => testMock.retrySync()).thenReturn(null);

        final testCubit = SyncCubit(testMock);
        
        // Initialize to set up stream listeners
        testCubit.init();
        
        // Give streams time to emit values and update state
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Now syncNow should call retrySync since pendingCount is > 0
        testCubit.syncNow();
        
        // Verify retrySync was called
        verify(() => testMock.retrySync()).called(1);
      },
    );

    test(
      'does not call retrySync when pendingCount == 0',
      () {
        // Use the default setup from setUp() which has pendingCount = 0
        cubit.init();
        
        // syncNow() should return early since pendingCount == 0
        cubit.syncNow();
        
        // Verify retrySync was never called
        verifyNever(() => mockSyncOrchestrator.retrySync());
      },
    );
  });

  group('SyncCubit - stream mapping', () {
    blocTest<SyncCubit, SyncState>(
      'maps orchestrator status stream into UI states',
      build: () {
        when(() => mockSyncOrchestrator.statusStream).thenAnswer(
          (_) => Stream<SyncStatus>.fromIterable([
            const SyncStatus.syncing(),
            const SyncStatus.error('boom'),
            const SyncStatus.idle(),
          ]),
        );
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        const SyncState.syncing(pendingCount: 0),
        const SyncState.error(
          pendingCount: 0,
          message: 'boom',
          failure: SyncFailure('boom'),
        ),
        isA<SyncState>().having(
          (s) => s.maybeMap(idle: (i) => i.pendingCount, orElse: () => -1),
          'pendingCount',
          0,
        ),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      'maps pending count stream into current state',
      build: () {
        when(
          () => mockSyncOrchestrator.pendingCountStream,
        ).thenAnswer((_) => Stream<int>.fromIterable([2, 5]));
        return cubit;
      },
      act: (cubit) => cubit.init(),
      expect: () => [
        const SyncState.idle(pendingCount: 2),
        const SyncState.idle(pendingCount: 5),
      ],
    );
  });
}
