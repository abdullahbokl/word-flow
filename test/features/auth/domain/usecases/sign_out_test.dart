import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/sync/sync_orchestrator.dart';
import 'package:word_flow/core/sync/sync_preferences.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/domain/usecases/sign_out_and_clear_local.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockWordRepository extends Mock implements WordRepository {}

class MockSyncPreferences extends Mock implements SyncPreferences {}

class MockAppLogger extends Mock implements AppLogger {}

class MockSyncOrchestrator extends Mock implements SyncOrchestrator {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockWordRepository mockWordRepository;
  late MockSyncPreferences mockSyncPreferences;
  late MockAppLogger mockLogger;
  late MockSyncOrchestrator mockSyncOrchestrator;
  late SignOutAndClearLocal useCase;

  const userId = 'user-123';

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockWordRepository = MockWordRepository();
    mockSyncPreferences = MockSyncPreferences();
    mockLogger = MockAppLogger();
    mockSyncOrchestrator = MockSyncOrchestrator();

    when(() => mockSyncOrchestrator.cancelInFlightSync()).thenReturn(null);

    useCase = SignOutAndClearLocal(
      mockAuthRepository,
      mockWordRepository,
      mockSyncPreferences,
      mockLogger,
      mockSyncOrchestrator,
    );
  });

  tearDown(() {
    reset(mockAuthRepository);
    reset(mockWordRepository);
    reset(mockSyncPreferences);
    reset(mockLogger);
    reset(mockSyncOrchestrator);
  });

  group('SignOutAndClearLocal', () {
    test('Successful sign out clears correct userId words', () async {
      when(() => mockAuthRepository.currentUserId).thenReturn(userId);
      when(
        () => mockWordRepository.clearLocalWords(userId),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockSyncPreferences.clearUserTimestamp(userId),
      ).thenAnswer((_) async {});
      when(
        () => mockWordRepository.clearGuestWords(),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockAuthRepository.signOut(),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right<Failure, void>(null));
      verify(() => mockSyncOrchestrator.cancelInFlightSync()).called(1);
      verify(() => mockWordRepository.clearLocalWords(userId)).called(1);
      verify(() => mockWordRepository.clearGuestWords()).called(1);
      verify(() => mockAuthRepository.signOut()).called(1);
    });

    test('Sign out still succeeds even if clearLocalWords throws', () async {
      when(() => mockAuthRepository.currentUserId).thenReturn(userId);
      when(
        () => mockWordRepository.clearLocalWords(userId),
      ).thenThrow(Exception('disk io error'));
      when(
        () => mockAuthRepository.signOut(),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockLogger.error(any(), any<dynamic>(), any<dynamic>()),
      ).thenReturn(null);

      final result = await useCase();

      expect(result, const Right<Failure, void>(null));
      verify(() => mockWordRepository.clearLocalWords(userId)).called(1);
      verify(() => mockAuthRepository.signOut()).called(1);
    });

    test('Sync timestamps are cleared for the userId', () async {
      when(() => mockAuthRepository.currentUserId).thenReturn(userId);
      when(
        () => mockWordRepository.clearLocalWords(userId),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockSyncPreferences.clearUserTimestamp(userId),
      ).thenAnswer((_) async {});
      when(
        () => mockWordRepository.clearGuestWords(),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockAuthRepository.signOut(),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right<Failure, void>(null));
      verify(() => mockSyncPreferences.clearUserTimestamp(userId)).called(1);
    });
  });
}
