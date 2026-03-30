import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/utils/rate_limiter.dart';
import 'package:word_flow/core/utils/rate_limiter_storage.dart';
import 'package:word_flow/features/auth/domain/entities/auth_state_change.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_out_and_clear_local.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSignInWithEmailUseCase extends Mock implements SignInWithEmailUseCase {}

class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}

class MockSignOutAndClearLocal extends Mock implements SignOutAndClearLocal {}

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
        super(storage: _NoopRateLimiterStorage(), storageKey: 'auth_test') {
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
  late MockAuthRepository mockAuthRepository;
  late MockSignInWithEmailUseCase mockSignInUseCase;
  late MockSignUpWithEmailUseCase mockSignUpUseCase;
  late MockSignOutAndClearLocal mockSignOutUseCase;
  late MockRateLimiter mockRateLimiter;
  late StreamController<AuthStateChange> authStateController;

  const testUser = AuthUser(id: 'user-1', email: 'user@example.com');

  AuthCubit buildCubit({RateLimiter? rateLimiter}) {
    return AuthCubit(
      mockAuthRepository,
      mockSignInUseCase,
      mockSignUpUseCase,
      mockSignOutUseCase,
      rateLimiter ?? mockRateLimiter,
    );
  }

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSignInUseCase = MockSignInWithEmailUseCase();
    mockSignUpUseCase = MockSignUpWithEmailUseCase();
    mockSignOutUseCase = MockSignOutAndClearLocal();
    mockRateLimiter = MockRateLimiter();
    authStateController = StreamController<AuthStateChange>.broadcast();

    when(() => mockAuthRepository.authStateStream)
        .thenAnswer((_) => authStateController.stream);
    when(() => mockRateLimiter.initialize()).thenAnswer((_) async {});
    when(() => mockRateLimiter.canAttempt()).thenReturn(true);
    when(() => mockRateLimiter.recordAttempt()).thenAnswer((_) async {});
    when(() => mockRateLimiter.reset()).thenAnswer((_) async {});
    when(() => mockRateLimiter.remainingCooldown).thenReturn(null);
  });

  tearDown(() async {
    await authStateController.close();
  });

  group('AuthCubit.init', () {
    blocTest<AuthCubit, AuthState>(
      'init() with existing session -> emits [loading, authenticated(user)]',
      build: () {
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        return buildCubit();
      },
      act: (cubit) async => cubit.init(),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(testUser),
      ],
      verify: (_) {
        verify(() => mockRateLimiter.initialize()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'init() with no session -> emits [loading, guest]',
      build: () {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        return buildCubit();
      },
      act: (cubit) async => cubit.init(),
      expect: () => [const AuthState.loading(), const AuthState.guest()],
    );

    blocTest<AuthCubit, AuthState>(
      'init() called twice -> only processes once (_isInitialized guard)',
      build: () {
        when(() => mockAuthRepository.currentUser).thenReturn(null);
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.init();
        await cubit.init();
      },
      expect: () => [const AuthState.loading(), const AuthState.guest()],
      verify: (_) {
        verify(() => mockRateLimiter.initialize()).called(1);
        verify(() => mockAuthRepository.authStateStream).called(1);
      },
    );
  });

  group('AuthCubit.authStateStream', () {
    blocTest<AuthCubit, AuthState>(
      'authStateStream signedIn event -> emits authenticated(user)',
      build: () {
        var currentUserCalls = 0;
        when(() => mockAuthRepository.currentUser).thenAnswer((_) {
          currentUserCalls += 1;
          return currentUserCalls == 1 ? null : testUser;
        });
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.init();
        authStateController.add(AuthStateChange.signedIn);
      },
      wait: const Duration(milliseconds: 1),
      expect: () => [
        const AuthState.loading(),
        const AuthState.guest(),
        const AuthState.authenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'authStateStream signedOut event -> emits guest',
      build: () {
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.init();
        authStateController.add(AuthStateChange.signedOut);
      },
      wait: const Duration(milliseconds: 1),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(testUser),
        const AuthState.guest(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'authStateStream unknown event -> re-checks session (verify _checkInitialSession called)',
      build: () {
        var currentUserCalls = 0;
        when(() => mockAuthRepository.currentUser).thenAnswer((_) {
          currentUserCalls += 1;
          return currentUserCalls == 1 ? null : testUser;
        });
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.init();
        authStateController.add(AuthStateChange.unknown);
      },
      wait: const Duration(milliseconds: 1),
      expect: () => [
        const AuthState.loading(),
        const AuthState.guest(),
        const AuthState.authenticated(testUser),
      ],
      verify: (_) {
        // Unknown event reads currentUser once in handler + once in _checkInitialSession,
        // in addition to init()'s initial session read.
        verify(() => mockAuthRepository.currentUser).called(3);
      },
    );
  });

  group('AuthCubit actions', () {
    blocTest<AuthCubit, AuthState>(
      'signIn() valid -> emits [loading, authenticated]',
      build: () {
        when(() => mockSignInUseCase('user@example.com', 'Password1'))
            .thenAnswer((_) async => const Right(testUser));
        return buildCubit();
      },
      act: (cubit) => cubit.signIn('user@example.com', 'Password1'),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(testUser),
      ],
      verify: (_) {
        verify(() => mockSignInUseCase('user@example.com', 'Password1'))
            .called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'signIn() invalid email -> emits [loading, error] (no network call made)',
      build: () {
        when(() => mockSignInUseCase('invalid-email', 'Password1')).thenAnswer(
          (_) async => const Left(AuthFailure('Invalid email format')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.signIn('invalid-email', 'Password1'),
      expect: () => [
        const AuthState.loading(),
        const AuthState.error('Invalid email format'),
      ],
      verify: (_) {
        verify(() => mockSignInUseCase('invalid-email', 'Password1')).called(1);
        verifyNever(
          () => mockAuthRepository.signInWithEmail(any(), any()),
        );
      },
    );

    blocTest<AuthCubit, AuthState>(
      'signIn() rate limited -> emits rateLimited with remainingCooldown',
      build: () {
        when(() => mockRateLimiter.canAttempt()).thenReturn(false);
        when(() => mockRateLimiter.remainingCooldown)
            .thenReturn(const Duration(seconds: 30));
        return buildCubit();
      },
      act: (cubit) => cubit.signIn('user@example.com', 'Password1'),
      expect: () => [const AuthState.rateLimited(Duration(seconds: 30))],
      verify: (_) {
        verifyNever(() => mockSignInUseCase(any(), any()));
      },
    );

    blocTest<AuthCubit, AuthState>(
      'logOut() -> emits [loading, guest]',
      build: () {
        when(() => mockSignOutUseCase())
            .thenAnswer((_) async => const Right(null));
        return buildCubit();
      },
      act: (cubit) => cubit.logOut(),
      expect: () => [const AuthState.loading(), const AuthState.guest()],
      verify: (_) {
        verify(() => mockSignOutUseCase()).called(1);
      },
    );
  });

  group('AuthCubit rate limiter with fake_async', () {
    test('cooldown expires and signIn can proceed after fake time elapses', () {
      fakeAsync((async) {
        final clock = async.getClock(DateTime(2026, 1, 1));
        final limiter = _CooldownRateLimiter(
          now: () => clock.now(),
          initialCooldown: const Duration(seconds: 5),
        );

        when(() => mockAuthRepository.authStateStream)
            .thenAnswer((_) => const Stream.empty());
        when(() => mockSignInUseCase('user@example.com', 'Password1'))
            .thenAnswer((_) async => const Right(testUser));

        final cubit = buildCubit(rateLimiter: limiter);
        final emitted = <AuthState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.signIn('user@example.com', 'Password1');
        async.flushMicrotasks();

        expect(
          emitted,
          contains(const AuthState.rateLimited(Duration(seconds: 5))),
        );

        async.elapse(const Duration(seconds: 6));
        cubit.signIn('user@example.com', 'Password1');
        async.flushMicrotasks();

        expect(emitted, contains(const AuthState.authenticated(testUser)));

        unawaited(sub.cancel());
        unawaited(cubit.close());
        async.flushMicrotasks();
      });
    });
  });
}
