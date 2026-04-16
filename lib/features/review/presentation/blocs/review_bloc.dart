import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/core/notifications/notification_service.dart';
import 'package:wordflow/features/lexicon/domain/commands/word_commands.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/usecases/get_words.dart';
import 'package:wordflow/features/lexicon/domain/usecases/update_word.dart';
import 'package:wordflow/features/lexicon/domain/usecases/watch_words.dart';
import 'package:wordflow/features/review/domain/algorithms/sm2_algorithm.dart';
import 'package:wordflow/features/review/presentation/blocs/review_event.dart';
import 'package:wordflow/features/review/presentation/blocs/review_state.dart';

export 'review_event.dart';
export 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc({
    required WatchWords watchWords,
    required UpdateWord updateWord,
    required NotificationService notificationService,
  })  : _watchWords = watchWords,
        _updateWord = updateWord,
        _notificationService = notificationService,
        super(const ReviewInitial()) {
    on<LoadDueReviews>(_onLoadDueReviews, transformer: restartable());
    on<SubmitReview>(_onSubmitReview, transformer: sequential());
    on<SkipReview>(_onSkipReview, transformer: sequential());
  }

  final WatchWords _watchWords;
  final UpdateWord _updateWord;
  final NotificationService _notificationService;

  StreamSubscription? _wordsSub;

  Future<void> _onLoadDueReviews(
    LoadDueReviews event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    await emit.forEach<Either<Failure, List<WordEntity>>>(
      _watchWords(const LexiconQueryParams(filter: WordFilter.due)),
      onData: (result) {
        return result.fold(
          (failure) {
            addError(failure);
            return state;
          },
          (words) {
            if (words.isEmpty && state is! ReviewInitial) {
              return const ReviewCompleted();
            } else {
              return ReviewLoaded(dueWords: words);
            }
          },
        );
      },
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state;
      },
    );
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReviewLoaded) return;

    final word = currentState.dueWords.firstWhere((w) => w.id == event.wordId);
    final schedule = word.reviewSchedule;

    if (schedule == null) return;

    final nextSchedule =
        SM2Algorithm.calculateNextReview(schedule, event.quality);

    final result = await _updateWord(UpdateWordCommand(
      id: word.id,
      reviewSchedule: nextSchedule,
    )).run();

    await result.fold(
      (failure) async => emit(ReviewError(failure.toString())),
      (updatedWord) async {
        await _notificationService.scheduleNotification(
          updatedWord.id,
          'Time to review: ${updatedWord.text}',
          'Time to review: ${updatedWord.text}',
          nextSchedule.nextReviewDate,
        );
      },
    );
  }

  Future<void> _onSkipReview(
    SkipReview event,
    Emitter<ReviewState> emit,
  ) async {
    unawaited(_notificationService.cancelNotification(event.wordId));
  }

  @override
  Future<void> close() async {
    await _wordsSub?.cancel();
    return super.close();
  }
}
