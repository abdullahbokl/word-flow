import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/database/write_queue.dart';
import 'package:word_flow/core/di/injection.dart' show getIt;
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/features/auth/data/services/migration_service.dart';
import 'package:word_flow/features/auth/domain/entities/auth_state_change.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/repositories/word_repository_impl.dart';
import 'package:word_flow/features/vocabulary/domain/entities/text_analysis_config.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/vocabulary/domain/services/text_analysis_service.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/adopt_guest_words.dart';
import 'package:word_flow/features/word_learning/domain/usecases/process_script.dart';
import 'package:word_flow/features/word_learning/domain/usecases/save_processed_words.dart';
import 'package:word_flow/features/vocabulary/data/services/isolate_text_analysis_service.dart';

class _TestWriteQueue implements LocalWriteQueue {
  @override
  Future<void> enqueue(Future<void> Function() job) => job();

  @override
  Future<void> close() async {}

  @override
  int get pendingCount => 0;
}

class _FakeAuthRepository implements AuthRepository {
  AuthUser? _current;

  @override
  Stream<AuthStateChange> get authStateStream => const Stream.empty();

  @override
  AuthUser? get currentUser => _current;

  @override
  String? get currentUserId => _current?.id;

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    final user = AuthUser(id: 'signin-user', email: email);
    _current = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmail(
    String email,
    String password,
  ) async {
    final user = AuthUser(id: 'new-user-123', email: email);
    _current = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    _current = null;
    return const Right(null);
  }
}

void main() {
  late WordFlowDatabase testDb;
  late GetIt sl;

  setUp(() async {
    sl = getIt;
    await sl.reset();

    testDb = WordFlowDatabase.test(NativeDatabase.memory());

    final logger = AppLogger();
    final writeQueue = _TestWriteQueue();

    sl.registerSingleton<WordFlowDatabase>(testDb);
    sl.registerSingleton<AppLogger>(logger);
    sl.registerSingleton<LocalWriteQueue>(writeQueue);

    sl.registerLazySingleton<WordLocalSource>(() => WordLocalSourceImpl(sl()));
    sl.registerLazySingleton<SyncLocalSource>(() => SyncLocalSourceImpl(sl()));
    sl.registerLazySingleton<WordRepository>(
      () => WordRepositoryImpl(sl(), sl(), sl(), sl()),
    );

    sl.registerLazySingleton<TextAnalysisService>(
      () => IsolateTextAnalysisService(),
    );
    sl.registerLazySingleton<ProcessScript>(() => ProcessScript(sl(), sl()));
    sl.registerLazySingleton<SaveProcessedWords>(
      () => SaveProcessedWords(sl()),
    );

    sl.registerLazySingleton<AuthRepository>(() => _FakeAuthRepository());
    sl.registerLazySingleton<SignUpWithEmailUseCase>(
      () => SignUpWithEmailUseCase(sl()),
    );

    sl.registerLazySingleton<AdoptGuestWords>(() => AdoptGuestWords(sl()));
    sl.registerLazySingleton<MigrationService>(
      () => MigrationService(sl(), sl(), sl()),
    );
  });

  tearDown(() async {
    await sl<WordFlowDatabase>().close();
    await sl.reset();
  });

  group('Guest -> Auth migration flow', () {
    test('Guest user creates words, signs up, words are migrated', () async {
      final processScript = sl<ProcessScript>();
      final saveProcessedWords = sl<SaveProcessedWords>();
      final wordRepo = sl<WordRepository>();
      final signUpWithEmailUseCase = sl<SignUpWithEmailUseCase>();
      final migrationService = sl<MigrationService>();

      const config = TextAnalysisConfig(
        useStemming: false,
        stopWords: {},
        language: 'en',
        minWordLength: 1,
      );

      // 1. Guest processes script and saves analyzed words.
      final analysisResult = await processScript(
        'hello world flutter dart',
        userId: null,
        config: config,
      );
      expect(analysisResult.isRight(), isTrue);

      final wordsToSave = analysisResult.fold(
        (_) => throw StateError('Expected analysis to succeed'),
        (r) => r.words,
      );
      final saveResult = await saveProcessedWords(wordsToSave, userId: null);
      expect(saveResult.isRight(), isTrue);

      final guestWordsAfterSave = await sl<WordFlowDatabase>()
          .watchWords(userId: null)
          .first;
      expect(guestWordsAfterSave.length, 4);
      expect(guestWordsAfterSave.every((w) => w.userId == 'GUEST'), isTrue);

      // 2. Mark flutter as known.
      final toggleResult = await wordRepo.toggleKnown('flutter', userId: null);
      expect(toggleResult.isRight(), isTrue);

      final flutterWordBeforeMigration = await sl<WordFlowDatabase>()
          .getWordByText('flutter', userId: null);
      expect(flutterWordBeforeMigration, isNotNull);
      expect(flutterWordBeforeMigration!.isKnown, isTrue);

      // 3. Sign up.
      final signUpResult = await signUpWithEmailUseCase(
        'test@example.com',
        'Password1',
      );
      expect(signUpResult.isRight(), isTrue);
      final newUser = signUpResult.fold(
        (_) => throw StateError('Expected sign up success'),
        (user) => user,
      );

      // 4. Migrate guest words.
      final migrateResult = await migrationService.migrateGuestData(newUser.id);
      expect(migrateResult, const Right<Failure, int>(4));

      // 5. Verify all 4 words now belong to the new user.
      final userWords = await sl<WordFlowDatabase>()
          .watchWords(userId: newUser.id)
          .first;
      expect(userWords.length, 4);
      expect(userWords.every((w) => w.userId == newUser.id), isTrue);

      // 6. Verify flutter remains known.
      final flutterWordAfterMigration = await sl<WordFlowDatabase>()
          .getWordByText('flutter', userId: newUser.id);
      expect(flutterWordAfterMigration, isNotNull);
      expect(flutterWordAfterMigration!.isKnown, isTrue);

      // 7. Verify no guest words remain.
      final guestWordsAfterMigration = await sl<WordFlowDatabase>()
          .watchWords(userId: null)
          .first;
      expect(guestWordsAfterMigration, isEmpty);

      // 8. Verify sync queue has 4 upsert entries.
      final queue = await sl<WordFlowDatabase>().getSyncQueue(20);
      expect(queue.length, 4);
      expect(queue.every((q) => q.operation == 'upsert'), isTrue);
    });

    test('Guest discards data on sign in', () async {
      final processScript = sl<ProcessScript>();
      final saveProcessedWords = sl<SaveProcessedWords>();
      final migrationService = sl<MigrationService>();

      const config = TextAnalysisConfig(
        useStemming: false,
        stopWords: {},
        language: 'en',
        minWordLength: 1,
      );

      // 1. As guest: create 2 words.
      final analysisResult = await processScript(
        'hello world',
        userId: null,
        config: config,
      );
      expect(analysisResult.isRight(), isTrue);
      final wordsToSave = analysisResult.fold(
        (_) => throw StateError('Expected analysis to succeed'),
        (r) => r.words,
      );
      final saveResult = await saveProcessedWords(wordsToSave, userId: null);
      expect(saveResult.isRight(), isTrue);

      final guestWordsBeforeDiscard = await sl<WordFlowDatabase>()
          .watchWords(userId: null)
          .first;
      expect(guestWordsBeforeDiscard.length, 2);

      // 2. Discard guest data.
      final discardResult = await migrationService.discardGuestData();
      expect(discardResult, const Right<Failure, void>(null));

      final guestWordsAfterDiscard = await sl<WordFlowDatabase>()
          .watchWords(userId: null)
          .first;
      expect(guestWordsAfterDiscard, isEmpty);
    });
  });
}
