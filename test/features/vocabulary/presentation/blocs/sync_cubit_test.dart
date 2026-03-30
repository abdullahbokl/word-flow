import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/core/sync/sync_orchestrator.dart';
import 'package:word_flow/core/sync/sync_status.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';

class MockSyncOrchestrator extends Mock implements SyncOrchestrator {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SyncCubit cubit;
  late MockSyncOrchestrator mockSyncOrchestrator;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockSyncOrchestrator = MockSyncOrchestrator();
    mockAuthRepository = MockAuthRepository();

    when(
      () => mockSyncOrchestrator.pendingCountStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockSyncOrchestrator.statusStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockSyncOrchestrator.retrySync()).thenReturn(null);
    when(() => mockAuthRepository.authStateStream)
      .thenAnswer((_) => const Stream.empty());
    when(() => mockAuthRepository.currentUserId).thenReturn('user-1');

    cubit = SyncCubit(mockSyncOrchestrator, mockAuthRepository);
  });

  group('SyncCubit - syncNow delegation', () {
    blocTest<SyncCubit, SyncState>(
      'calls SyncOrchestrator.retrySync and emits no local state directly',
      build: () => cubit,
      act: (cubit) => cubit.syncNow(),
      expect: () => [],
      verify: (_) {
        verify(() => mockSyncOrchestrator.retrySync()).called(1);
      },
    );
  });

  group('SyncCubit - stream mapping', () {
    blocTest<SyncCubit, SyncState>(
      'maps orchestrator status stream into UI states',
      build: () {
        when(
          () => mockSyncOrchestrator.statusStream,
        ).thenAnswer(
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
