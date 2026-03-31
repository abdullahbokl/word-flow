import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInWithEmailUseCase signInWithEmailUseCase;
  late SignUpWithEmailUseCase signUpWithEmailUseCase;

  const validEmail = 'user+tag@mail.example.com';
  const validPassword = 'Password1';
  const shortPassword = 'Pass1';
  const invalidEmail = 'invalid-email';
  const emptyPassword = '';
  const authUser = AuthUser(id: 'user-123', email: validEmail);
  const repoFailure = AuthFailure('Invalid credentials');

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInWithEmailUseCase = SignInWithEmailUseCase(mockAuthRepository);
    signUpWithEmailUseCase = SignUpWithEmailUseCase(mockAuthRepository);
  });

  tearDown(() {
    reset(mockAuthRepository);
  });

  group('SignInWithEmailUseCase', () {
    test('Valid credentials -> Right(AuthUser)', () async {
      when(
        () => mockAuthRepository.signInWithEmail(validEmail, validPassword),
      ).thenAnswer((_) async => const Right(authUser));

      final result = await signInWithEmailUseCase(validEmail, validPassword);

      expect(result, const Right<Failure, AuthUser>(authUser));
      verify(
        () => mockAuthRepository.signInWithEmail(validEmail, validPassword),
      ).called(1);
    });

    test('Invalid email format -> Left(AuthFailure)', () async {
      final result = await signInWithEmailUseCase(invalidEmail, validPassword);

      expect(
        result,
        const Left<Failure, AuthUser>(AuthFailure('Invalid email format')),
      );
      verifyNever(() => mockAuthRepository.signInWithEmail(any(), any()));
    });

    test('Empty password -> Left(AuthFailure)', () async {
      final result = await signInWithEmailUseCase(validEmail, emptyPassword);

      expect(
        result,
        const Left<Failure, AuthUser>(
          AuthFailure('Password must be at least 8 characters'),
        ),
      );
      verifyNever(() => mockAuthRepository.signInWithEmail(any(), any()));
    });

    test('Password too short -> Left(AuthFailure)', () async {
      final result = await signInWithEmailUseCase(validEmail, shortPassword);

      expect(
        result,
        const Left<Failure, AuthUser>(
          AuthFailure('Password must be at least 8 characters'),
        ),
      );
      verifyNever(() => mockAuthRepository.signInWithEmail(any(), any()));
    });

    test(
      'Repository returns Left(AuthFailure) -> propagated correctly',
      () async {
        when(
          () => mockAuthRepository.signInWithEmail(validEmail, validPassword),
        ).thenAnswer((_) async => const Left(repoFailure));

        final result = await signInWithEmailUseCase(validEmail, validPassword);

        expect(result, const Left<Failure, AuthUser>(repoFailure));
        verify(
          () => mockAuthRepository.signInWithEmail(validEmail, validPassword),
        ).called(1);
      },
    );
  });

  group('SignUpWithEmailUseCase', () {
    test('Valid credentials -> Right(AuthUser)', () async {
      when(
        () => mockAuthRepository.signUpWithEmail(validEmail, validPassword),
      ).thenAnswer((_) async => const Right(authUser));

      final result = await signUpWithEmailUseCase(validEmail, validPassword);

      expect(result, const Right<Failure, AuthUser>(authUser));
      verify(
        () => mockAuthRepository.signUpWithEmail(validEmail, validPassword),
      ).called(1);
    });

    test('Invalid email format -> Left(AuthFailure)', () async {
      final result = await signUpWithEmailUseCase(invalidEmail, validPassword);

      expect(
        result,
        const Left<Failure, AuthUser>(AuthFailure('Invalid email format')),
      );
      verifyNever(() => mockAuthRepository.signUpWithEmail(any(), any()));
    });

    test(
      'Repository returns Left(AuthFailure) -> propagated correctly',
      () async {
        when(
          () => mockAuthRepository.signUpWithEmail(validEmail, validPassword),
        ).thenAnswer((_) async => const Left(repoFailure));

        final result = await signUpWithEmailUseCase(validEmail, validPassword);

        expect(result, const Left<Failure, AuthUser>(repoFailure));
        verify(
          () => mockAuthRepository.signUpWithEmail(validEmail, validPassword),
        ).called(1);
      },
    );
  });
}
