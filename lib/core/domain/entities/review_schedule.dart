import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_schedule.freezed.dart';
part 'review_schedule.g.dart';

@freezed
abstract class ReviewSchedule with _$ReviewSchedule {
  const factory ReviewSchedule({
    required DateTime nextReviewDate,
    required int interval,
    required int repetition,
    required double easinessFactor,
  }) = _ReviewSchedule;

  const ReviewSchedule._();

  factory ReviewSchedule.fromJson(Map<String, dynamic> json) =>
      _$ReviewScheduleFromJson(json);
}
