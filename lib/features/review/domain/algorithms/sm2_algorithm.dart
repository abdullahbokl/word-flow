import 'package:wordflow/core/domain/entities/review_schedule.dart';

/// SM-2 Algorithm implementation for spaced repetition.
///
/// Based on the SuperMemo-2 algorithm.
class SM2Algorithm {
  /// Calculates the next review schedule based on the current schedule and recall quality.
  ///
  /// Quality mapping:
  /// - Hard: 2
  /// - Good: 4
  /// - Easy: 5
  ///
  /// Logic:
  /// - If quality < 3: repetition reset to 0, interval set to 1.
  /// - If quality >= 3: repetition increments and interval progression 1 -> 6 -> round(previous * EF).
  /// - EF update formula: EF = EF + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)).
  /// - EF is clamped to a minimum of 1.3.
  static ReviewSchedule calculateNextReview(
      ReviewSchedule schedule, int quality) {
    int nextRepetition;
    int nextInterval;
    double nextEasinessFactor;

    if (quality < 3) {
      nextRepetition = 0;
      nextInterval = 1;
      nextEasinessFactor = schedule.easinessFactor;
    } else {
      nextRepetition = schedule.repetition + 1;

      if (nextRepetition == 1) {
        nextInterval = 1;
      } else if (nextRepetition == 2) {
        nextInterval = 6;
      } else {
        nextInterval = (schedule.interval * schedule.easinessFactor).round();
      }

      // Update Easiness Factor
      nextEasinessFactor = schedule.easinessFactor +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

      if (nextEasinessFactor < 1.3) {
        nextEasinessFactor = 1.3;
      }
    }

    final nextReviewDate = DateTime.now().add(Duration(days: nextInterval));

    return schedule.copyWith(
      nextReviewDate: nextReviewDate,
      interval: nextInterval,
      repetition: nextRepetition,
      easinessFactor: nextEasinessFactor,
    );
  }
}
