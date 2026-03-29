import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fake_async/fake_async.dart';
import 'package:word_flow/core/sync/connectivity_monitor.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/pull_remote_changes.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/sync_pending_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_pending_count.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/usecases/usecase.dart';

class MockWatchPendingCount extends Mock implements WatchPendingCount {}
class MockSyncPendingWords extends Mock implements SyncPendingWords {}
class MockPullRemoteChanges extends Mock implements PullRemoteChanges {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockConnectivityMonitor extends Mock implements ConnectivityMonitor {}

void main() {
  late SyncCubit cubit;
  late MockWatchPendingCount mockWatchPendingCount;
  late MockSyncPendingWords mockSyncPendingWords;
  late MockPullRemoteChanges mockPullRemoteChanges;
  late MockAuthRepository mockAuthRepository;
  late MockConnectivityMonitor mockConnectivityMonitor;

  setUp(() {
    mockWatchPendingCount = MockWatchPendingCount();
    mockSyncPendingWords = MockSyncPendingWords();
    mockPullRemoteChanges = MockPullRemoteChanges();
    mockAuthRepository = MockAuthRepository();
    mockConnectivityMonitor = MockConnectivityMonitor();
    
    registerFallbackValue(const NoParams());

    // Default behaviors
    when(() => mockWatchPendingCount(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockConnectivityMonitor.statusStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockConnectivityMonitor.isOnline)
        .thenAnswer((_) async => true);
    when(() => mockConnectivityMonitor.checkReachability())
        .thenAnswer((_) async => true);
    when(() => mockAuthRepository.currentUserId)
        .thenReturn(null);

    cubit = SyncCubit(
      mockWatchPendingCount,
      mockSyncPendingWords,
      mockPullRemoteChanges,
      mockAuthRepository,
      mockConnectivityMonitor,
    );
  });

  group('SyncCubit - syncNow (Guards)', () {
    blocTest<SyncCubit, SyncState>(
      'should not emit syncing when device is offline',
      build: () {
        when(() => mockConnectivityMonitor.isOnline).thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.syncNow(),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockSyncPendingWords(any()));
      },
    );

    blocTest<SyncCubit, SyncState>(
      'should not emit syncing when reachability check fails',
      build: () {
        when(() => mockConnectivityMonitor.checkReachability()).thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.syncNow(),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockSyncPendingWords(any()));
      },
    );

    blocTest<SyncCubit, SyncState>(
      'should not start a second sync if already syncing',
      build: () {
        // Mock sync delay to keep it in syncing state
        when(() => mockSyncPendingWords(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return const Right(0);
        });
        return cubit;
      },
      seed: () => const SyncState.syncing(pendingCount: 1),
      act: (cubit) => cubit.syncNow(),
      expect: () => [], // No additional state emissions
      verify: (_) {
         // Should NOT have called syncPendingWords again (seed set it initially, but act should return early)
         verifyNever(() => mockSyncPendingWords(any()));
      },
    );
  });

  group('SyncCubit - syncNow (Flow)', () {
    blocTest<SyncCubit, SyncState>(
      'should emit syncing then idle on successful sync',
      build: () {
        when(() => mockSyncPendingWords(any())).thenAnswer((_) async => const Right(0));
        return cubit;
      },
      seed: () => const SyncState.idle(pendingCount: 1),
      act: (cubit) => cubit.syncNow(),
      expect: () => [
        const SyncState.syncing(pendingCount: 1),
        isA<SyncState>().having((s) => s.maybeMap(idle: (i) => i.lastSyncTime != null, orElse: () => false), 'lastSyncTime set', true),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      'should emit error when sync pending failure occurs',
      build: () {
        when(() => mockSyncPendingWords(any())).thenAnswer((_) async => const Left(SyncFailure('push error')));
        return cubit;
      },
      seed: () => const SyncState.idle(pendingCount: 1),
      act: (cubit) => cubit.syncNow(),
      expect: () => [
        const SyncState.syncing(pendingCount: 1),
        const SyncState.error(pendingCount: 1, message: 'push error'),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      'should pull remote changes if userId is present',
      build: () {
        when(() => mockAuthRepository.currentUserId).thenReturn('user-1');
        when(() => mockSyncPendingWords(any())).thenAnswer((_) async => const Right(0));
        when(() => mockPullRemoteChanges(any())).thenAnswer((_) async => const Right(0));
        return cubit;
      },
      seed: () => const SyncState.idle(pendingCount: 0),
      act: (cubit) => cubit.syncNow(),
      expect: () => [
        const SyncState.syncing(pendingCount: 0),
        isA<SyncState>().having((s) => s.maybeMap(idle: (i) => i.lastSyncTime != null, orElse: () => false), 'lastSyncTime set', true),
      ],
      verify: (_) {
        verify(() => mockPullRemoteChanges('user-1')).called(1);
      },
    );
  });

  group('Periodic Sync Timer', () {
    test('should trigger syncNow every 5 minutes', () {
      fakeAsync((async) {
        when(() => mockSyncPendingWords(any())).thenAnswer((_) async => const Right(0));
        
        cubit.init(); // Starts the periodic timer
        
        async.elapse(const Duration(minutes: 5));
        verify(() => mockSyncPendingWords(any())).called(1);
        
        async.elapse(const Duration(minutes: 5));
        verify(() => mockSyncPendingWords(any())).called(1);
      });
    });
  });
}
