import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/get_guest_words_count.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockWordRepository mockRepository;
  late GetGuestWordsCount useCase;

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = GetGuestWordsCount(mockRepository);
  });

  group('GetGuestWordsCount', () {
    test('should return count from repository', () async {
      when(() => mockRepository.getGuestWordsCount())
          .thenAnswer((_) async => const Right(5));

      final result = await useCase(const NoParams());

      expect(result, const Right(5));
      verify(() => mockRepository.getGuestWordsCount()).called(1);
    });
  });
}
