import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_event.freezed.dart';

@freezed
sealed class ReviewEvent with _$ReviewEvent {
  const factory ReviewEvent.loadDueReviews() = LoadDueReviews;
  const factory ReviewEvent.submitReview({
    required int wordId,
    required int quality,
  }) = SubmitReview;
  const factory ReviewEvent.skipReview(int wordId) = SkipReview;
}
