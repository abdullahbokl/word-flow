import 'package:flutter_test/flutter_test.dart';
import 'package:wordflow/core/domain/entities/review_schedule.dart';
import 'package:wordflow/features/review/domain/algorithms/sm2_algorithm.dart';

void main() {
  group('SM2Algorithm', () {
    late DateTime now;

    setUp(() {
      now = DateTime.now();
    });

    test('new word + Good(4) recall', () {
      final schedule = ReviewSchedule(
        nextReviewDate: now,
        interval: 0,
        repetition: 0,
        easinessFactor: 2.5,
      );

      final result = SM2Algorithm.calculateNextReview(schedule, 4);

      expect(result.repetition, 1);
      expect(result.interval, 1);
      // EF = 2.5 + (0.1 - (5-4)*(0.08 + (5-4)*0.02)) = 2.5 + (0.1 - 1*(0.08 + 0.02)) = 2.5 + 0 = 2.5
      expect(result.easinessFactor, 2.5);
      expect(result.nextReviewDate.difference(now).inDays, 1);
    });

    test('correct recall Good(4) - second repetition', () {
      final schedule = ReviewSchedule(
        nextReviewDate: now,
        interval: 1,
        repetition: 1,
        easinessFactor: 2.5,
      );

      final result = SM2Algorithm.calculateNextReview(schedule, 4);

      expect(result.repetition, 2);
      expect(result.interval, 6);
      expect(result.easinessFactor, 2.5);
    });

    test('correct recall Good(4) - third repetition', () {
      final schedule = ReviewSchedule(
        nextReviewDate: now,
        interval: 6,
        repetition: 2,
        easinessFactor: 2.5,
      );

      final result = SM2Algorithm.calculateNextReview(schedule, 4);

      expect(result.repetition, 3);
      expect(result.interval, 15); // 6 * 2.5 = 15
      expect(result.easinessFactor, 2.5);
    });

    test('easy recall Easy(5)', () {
      final schedule = ReviewSchedule(
        nextReviewDate: now,
        interval: 6,
        repetition: 2,
        easinessFactor: 2.5,
      );

      final result = SM2Algorithm.calculateNextReview(schedule, 5);

      expect(result.repetition, 3);
      expect(result.interval, 15);
      // EF = 2.5 + (0.1 - (5-5)*(0.08 + (5-5)*0.02)) = 2.5 + 0.1 = 2.6
      expect(result.easinessFactor, 2.6);
    });

    test('hard recall Hard(2)', () {
      final schedule = ReviewSchedule(
        nextReviewDate: now,
        interval: 15,
        repetition: 3,
        easinessFactor: 2.5,
      );

      final result = SM2Algorithm.calculateNextReview(schedule, 2);

      expect(result.repetition, 0);
      expect(result.interval, 1);
      expect(result.easinessFactor, 2.5); // EF doesn't change if quality < 3
    });

    test('lapse quality=0', () {
      final schedule = ReviewSchedule(
        nextReviewDate: now,
        interval: 15,
        repetition: 3,
        easinessFactor: 2.5,
      );

      final result = SM2Algorithm.calculateNextReview(schedule, 0);

      expect(result.repetition, 0);
      expect(result.interval, 1);
      expect(result.easinessFactor, 2.5);
    });

    test('EF floor clamp at 1.3', () {
      // EF = 1.3, quality = 3
      // EF = 1.3 + (0.1 - (5-3)*(0.08 + (5-3)*0.02)) = 1.3 + (0.1 - 2*(0.08 + 0.04)) = 1.3 + (0.1 - 0.24) = 1.3 - 0.14 = 1.16
      final schedule = ReviewSchedule(
        nextReviewDate: now,
        interval: 6,
        repetition: 2,
        easinessFactor: 1.3,
      );

      final result = SM2Algorithm.calculateNextReview(schedule, 3);

      expect(result.easinessFactor, 1.3);
    });
  });
}
