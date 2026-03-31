import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';

void main() {
  group('WordEntity.validated', () {
    test('throws when lastUpdated is more than 5 minutes in the future', () {
      final futureDate = DateTime.now().toUtc().add(const Duration(minutes: 6));

      expect(
        () => WordEntity.validated(
          id: 'word-1',
          wordText: 'example',
          lastUpdated: futureDate,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'lastUpdated is more than 5 minutes in the future — possible data corruption',
          ),
        ),
      );
    });

    test(
      'allows timestamps within 5 minutes of now (clock skew tolerance)',
      () {
        final withinTolerance = DateTime.now().toUtc().add(
          const Duration(minutes: 4, seconds: 59),
        );

        final entity = WordEntity.validated(
          id: 'word-2',
          wordText: 'example',
          lastUpdated: withinTolerance,
        );

        expect(entity.lastUpdated, withinTolerance);
      },
    );
  });
}
