import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordflow/core/domain/entities/review_schedule.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/notifications/notification_service.dart';
import 'package:wordflow/features/lexicon/domain/commands/word_commands.dart';
import 'package:wordflow/features/lexicon/domain/usecases/get_words.dart';
import 'package:wordflow/features/lexicon/domain/usecases/update_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/watch_words.dart';
import 'package:wordflow/features/review/presentation/blocs/review_bloc.dart';

class MockWatchWords extends Mock implements WatchWords {}

class MockUpdateWord extends Mock implements UpdateWord {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late ReviewBloc bloc;
  late MockWatchWords mockWatchWords;
  late MockUpdateWord mockUpdateWord;
  late MockNotificationService mockNotificationService;
  late StreamController<Either<Failure, List<WordEntity>>> wordsController;

  setUpAll(() {
    registerFallbackValue(const LexiconQueryParams());
    registerFallbackValue(const UpdateWordCommand(id: 1));
  });

  setUp(() {
    mockWatchWords = MockWatchWords();
    mockUpdateWord = MockUpdateWord();
    mockNotificationService = MockNotificationService();
    wordsController =
        StreamController<Either<Failure, List<WordEntity>>>.broadcast();

    when(() => mockWatchWords(any())).thenAnswer((_) => wordsController.stream);

    bloc = ReviewBloc(
      watchWords: mockWatchWords,
      updateWord: mockUpdateWord,
      notificationService: mockNotificationService,
    );
  });

  tearDown(() async {
    await wordsController.close();
    await bloc.close();
  });

  final tWord = WordEntity(
    id: 1,
    text: 'test',
    frequency: 1,
    isKnown: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isExcluded: false,
    reviewSchedule: ReviewSchedule(
      nextReviewDate: DateTime.now().subtract(const Duration(days: 1)),
      interval: 1,
      repetition: 1,
      easinessFactor: 2.5,
    ),
  );

  group('ReviewBloc', () {
    blocTest<ReviewBloc, ReviewState>(
      'emits [loading, loaded] when LoadDueReviews is added and stream emits words',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const ReviewEvent.loadDueReviews());
        unawaited(Future.microtask(() => wordsController.add(Right([tWord]))));
      },
      expect: () => [
        const ReviewState.loading(),
        ReviewState.loaded(dueWords: [tWord]),
      ],
    );

    blocTest<ReviewBloc, ReviewState>(
      'emits [loading, completed] when LoadDueReviews is added and stream emits empty list',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const ReviewEvent.loadDueReviews());
        unawaited(Future.microtask(() => wordsController.add(const Right([]))));
      },
      expect: () => [
        const ReviewState.loading(),
        const ReviewState.completed(),
      ],
    );

    blocTest<ReviewBloc, ReviewState>(
      'calls updateWord and scheduleNotification when SubmitReview is added',
      build: () => bloc,
      seed: () => ReviewState.loaded(dueWords: [tWord]),
      act: (bloc) async {
        when(() => mockUpdateWord(any()))
            .thenAnswer((_) => TaskEither.right(tWord));
        when(() => mockNotificationService.scheduleNotification(
            any(), any(), any(), any())).thenAnswer((_) async {});

        bloc.add(const ReviewEvent.submitReview(wordId: 1, quality: 4));
      },
      verify: (_) {
        verify(() => mockUpdateWord(any())).called(1);
        verify(() => mockNotificationService.scheduleNotification(
              tWord.id,
              any(),
              any(),
              any(),
            )).called(1);
      },
    );

    blocTest<ReviewBloc, ReviewState>(
      'calls cancelNotification when SkipReview is added',
      build: () => bloc,
      act: (bloc) async {
        when(() => mockNotificationService.cancelNotification(any()))
            .thenAnswer((_) async {});
        bloc.add(const ReviewEvent.skipReview(1));
      },
      verify: (_) {
        verify(() => mockNotificationService.cancelNotification(1)).called(1);
      },
    );
  });
}
