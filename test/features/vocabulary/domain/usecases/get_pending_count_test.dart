import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/usecases/usecase.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/get_pending_count.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockSyncRepository mockRepository;
  late GetPendingCount useCase;

  setUp(() {
    mockRepository = MockSyncRepository();
    useCase = GetPendingCount(mockRepository);
  });

  group('GetPendingCount', () {
    test('should return count from repository', () async {
      when(() => mockRepository.getPendingCount())
          .thenAnswer((_) async => const Right(10));

      final result = await useCase(const NoParams());

      expect(result, const Right(10));
      verify(() => mockRepository.getPendingCount()).called(1);
    });
  });
}
