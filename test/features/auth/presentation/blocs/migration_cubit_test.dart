import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/services/migration_service.dart';
import 'package:word_flow/core/utils/rate_limiter.dart';
import 'package:word_flow/core/utils/rate_limiter_storage.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/blocs/migration_cubit.dart';
import 'package:word_flow/features/auth/presentation/blocs/migration_state.dart';

class MockSignInWithEmailUseCase extends Mock implements SignInWithEmailUseCase {}

class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}

class MockMigrationService extends Mock implements MigrationService {}

class MockAuthCubit extends Mock implements AuthCubit {}

class MockRateLimiter extends Mock implements RateLimiter {}

class _NoopRateLimiterStorage implements RateLimiterStorage {
  @override
  Future<List<DateTime>> loadAttempts(String key) async => [];

  @override
  Future<void> saveAttempts(String key, List<DateTime> attempts) async {}
}

class _CooldownRateLimiter extends RateLimiter {
  _CooldownRateLimiter({
    required DateTime Function() now,
    required Duration initialCooldown,
  })  : _now = now,
        super(storage: _NoopRateLimiterStorage(), storageKey: 'migration_test') {
    _cooldownUntil = _now().add(initialCooldown);
  }

  final DateTime Function() _now;
  late DateTime _cooldownUntil;

  @override
  Future<void> initialize() async {}

  @override
  bool canAttempt() => !_now().isBefore(_cooldownUntil);

  @override
  Duration? get remainingCooldown {
    if (canAttempt()) return null;
    return _cooldownUntil.difference(_now());
  }

  @override
  Future<void> recordAttempt() async {}

  @override
  Future<void> reset() async {
    _cooldownUntil = _now();
  }
}

void main() {
  late MockSignInWithEmailUseCase mockSignInUseCase;
  late MockSignUpWithEmailUseCase mockSignUpUseCase;
  late MockMigrationService mockMigrationService;
  late MockAuthCubit mockAuthCubit;
  late MockRateLimiter mockRateLimiter;

  const testUser = AuthUser(id: 'user-1', email: 'user@example.com');

  MigrationCubit buildCubit({RateLimiter? rateLimiter}) {
    return MigrationCubit(
      mockSignInUseCase,
      mockSignUpUseCase,
      mockMigrationService,
      mockAuthCubit,
      rateLimiter ?? mockRateLimiter,
    );
  }

  setUp(() {
    mockSignInUseCase = MockSignInWithEmailUseCase();
    mockSignUpUseCase = MockSignUpWithEmailUseCase();
    mockMigrationService = MockMigrationService();
    mockAuthCubit = MockAuthCubit();
    mockRateLimiter = MockRateLimiter();

    when(() => mockRateLimiter.initialize()).thenAnswer((_) async {});
    when(() => mockRateLimiter.canAttempt()).thenReturn(true);
    when(() => mockRateLimiter.recordAttempt()).thenAnswer((_) async {});
    when(() => mockRateLimiter.reset()).thenAnswer((_) async {});
    when(() => mockRateLimiter.remainingCooldown).thenReturn(null);
    when(() => mockAuthCubit.onAuthenticatedWithMerge(testUser)).thenReturn(null);
    when(() => mockAuthCubit.onAuthenticatedWithDiscard(testUser)).thenReturn(null);
  });

  group('MigrationCubit.signIn', () {
    blocTest<MigrationCubit, MigrationState>(
      'signIn() with guestCount=0 -> no merge dialog, emits success',
      build: () {
        when(() => mockSignInUseCase('user@example.com', 'Password1'))
            .thenAnswer((_) async => const Right(testUser));
        when(() => mockMigrationService.getGuestWordsCount())
            .thenAnswer((_) async => const Right(0));
        return buildCubit();
      },
      act: (cubit) => cubit.signIn('user@example.com', 'Password1'),
      expect: () => [
        const MigrationState.loading(),
        const MigrationState.success(),
      ],
      verify: (_) {
        verify(() => mockMigrationService.getGuestWordsCount()).called(1);
        verify(() => mockAuthCubit.onAuthenticatedWithMerge(testUser)).called(1);
      },
    );

    blocTest<MigrationCubit, MigrationState>(
      'signIn() with guestCount=5 -> emits pendingMerge(user, 5)',
      build: () {
        when(() => mockSignInUseCase('user@example.com', 'Password1'))
            .thenAnswer((_) async => const Right(testUser));
        when(() => mockMigrationService.getGuestWordsCount())
            .thenAnswer((_) async => const Right(5));
        return buildCubit();
      },
      act: (cubit) => cubit.signIn('user@example.com', 'Password1'),
      expect: () => [
        const MigrationState.loading(),
        const MigrationState.pendingMerge(testUser, 5),
      ],
      verify: (_) {
        verifyNever(() => mockAuthCubit.onAuthenticatedWithMerge(testUser));
      },
    );

    blocTest<MigrationCubit, MigrationState>(
      'Rate limiting in signIn',
      build: () {
        when(() => mockRateLimiter.canAttempt()).thenReturn(false);
        when(() => mockRateLimiter.remainingCooldown)
            .thenReturn(const Duration(seconds: 20));
        return buildCubit();
      },
      act: (cubit) => cubit.signIn('user@example.com', 'Password1'),
      expect: () => [const MigrationState.rateLimited(Duration(seconds: 20))],
      verify: (_) {
        verifyNever(() => mockSignInUseCase(any(), any()));
      },
    );
  });

  group('MigrationCubit actions', () {
    blocTest<MigrationCubit, MigrationState>(
      'mergeAndSignIn(user) -> calls migrateGuestData, emits success',
      build: () {
        when(() => mockMigrationService.migrateGuestData(testUser.id))
            .thenAnswer((_) async => const Right(3));
        return buildCubit();
      },
      act: (cubit) => cubit.mergeAndSignIn(testUser),
      expect: () => [
        const MigrationState.loading(),
        const MigrationState.success(),
      ],
      verify: (_) {
        verify(() => mockMigrationService.migrateGuestData(testUser.id)).called(1);
        verify(() => mockAuthCubit.onAuthenticatedWithMerge(testUser)).called(1);
      },
    );

    blocTest<MigrationCubit, MigrationState>(
      'discardGuestAndSignIn(user) -> calls discardGuestData, emits success',
      build: () {
        when(() => mockMigrationService.discardGuestData())
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      act: (cubit) => cubit.discardGuestAndSignIn(testUser),
      expect: () => [
        const MigrationState.loading(),
        const MigrationState.success(),
      ],
      verify: (_) {
        verify(() => mockMigrationService.discardGuestData()).called(1);
        verify(() => mockAuthCubit.onAuthenticatedWithDiscard(testUser)).called(1);
      },
    );

    blocTest<MigrationCubit, MigrationState>(
      'signUp() -> calls migrateGuestData always (new users get their guest words migrated)',
      build: () {
        when(() => mockSignUpUseCase('new@example.com', 'Password1'))
            .thenAnswer((_) async => const Right(testUser));
        when(() => mockMigrationService.migrateGuestData(testUser.id))
            .thenAnswer((_) async => const Right(4));
        return buildCubit();
      },
      act: (cubit) => cubit.signUp('new@example.com', 'Password1'),
      expect: () => [
        const MigrationState.loading(),
        const MigrationState.success(),
      ],
      verify: (_) {
        verify(() => mockMigrationService.migrateGuestData(testUser.id)).called(1);
        verify(() => mockAuthCubit.onAuthenticatedWithMerge(testUser)).called(1);
      },
    );

    blocTest<MigrationCubit, MigrationState>(
      'Rate limiting in signUp',
      build: () {
        when(() => mockRateLimiter.canAttempt()).thenReturn(false);
        when(() => mockRateLimiter.remainingCooldown)
            .thenReturn(const Duration(seconds: 20));
        return buildCubit();
      },
      act: (cubit) => cubit.signUp('new@example.com', 'Password1'),
      expect: () => [const MigrationState.rateLimited(Duration(seconds: 20))],
      verify: (_) {
        verifyNever(() => mockSignUpUseCase(any(), any()));
      },
    );
  });

  group('MigrationCubit rate limiter with fake_async', () {
    test('cooldown expires and signIn/signUp proceed after fake time elapses', () {
      fakeAsync((async) {
        final clock = async.getClock(DateTime(2026, 1, 1));
        final limiter = _CooldownRateLimiter(
          now: () => clock.now(),
          initialCooldown: const Duration(seconds: 5),
        );

        when(() => mockSignInUseCase('user@example.com', 'Password1'))
            .thenAnswer((_) async => const Right(testUser));
        when(() => mockSignUpUseCase('new@example.com', 'Password1'))
            .thenAnswer((_) async => const Right(testUser));
        when(() => mockMigrationService.getGuestWordsCount())
            .thenAnswer((_) async => const Right(0));
        when(() => mockMigrationService.migrateGuestData(testUser.id))
            .thenAnswer((_) async => const Right(2));

        final cubit = buildCubit(rateLimiter: limiter);
        final emitted = <MigrationState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.signIn('user@example.com', 'Password1');
        async.flushMicrotasks();
        expect(
          emitted,
          contains(const MigrationState.rateLimited(Duration(seconds: 5))),
        );

        async.elapse(const Duration(seconds: 6));
        cubit.signIn('user@example.com', 'Password1');
        async.flushMicrotasks();

        expect(emitted, contains(const MigrationState.success()));

        // Reset back to blocked to validate signUp path as well.
        final secondLimiter = _CooldownRateLimiter(
          now: () => clock.now(),
          initialCooldown: const Duration(seconds: 3),
        );
        final cubit2 = buildCubit(rateLimiter: secondLimiter);
        final emitted2 = <MigrationState>[];
        final sub2 = cubit2.stream.listen(emitted2.add);

        cubit2.signUp('new@example.com', 'Password1');
        async.flushMicrotasks();
        expect(
          emitted2,
          contains(const MigrationState.rateLimited(Duration(seconds: 3))),
        );

        async.elapse(const Duration(seconds: 4));
        cubit2.signUp('new@example.com', 'Password1');
        async.flushMicrotasks();

        expect(emitted2, contains(const MigrationState.success()));

        unawaited(sub.cancel());
        unawaited(sub2.cancel());
        unawaited(cubit.close());
        unawaited(cubit2.close());
        async.flushMicrotasks();
      });
    });
  });
}
