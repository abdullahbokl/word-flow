import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/delete_word.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late MockWordRepository mockRepository;
  late DeleteWord useCase;

  setUpAll(() {
    registerFallbackValue(const DeleteWordParams(id: 'any'));
  });

  setUp(() {
    mockRepository = MockWordRepository();
    useCase = DeleteWord(mockRepository);
  });

  group('DeleteWord', () {
    const testWordId = 'word-1';
    const testUserId = 'user-1';

    test('should call repository.deleteWord with correct parameters', () async {
      when(() => mockRepository.deleteWord(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      await useCase(const DeleteWordParams(id: testWordId, userId: testUserId));

      verify(() => mockRepository.deleteWord(testWordId, userId: testUserId)).called(1);
    });

    test('should call repository.deleteWord with null userId when not provided', () async {
      when(() => mockRepository.deleteWord(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      await useCase(const DeleteWordParams(id: testWordId));

      verify(() => mockRepository.deleteWord(testWordId, userId: null)).called(1);
    });

    test('should return Right(null) on success', () async {
      when(() => mockRepository.deleteWord(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(const DeleteWordParams(id: testWordId, userId: testUserId));

      expect(result.isRight(), true);
    });

    test('should return Left(Failure) when repository fails', () async {
      const failure = DatabaseFailure('Failed to delete word');
      when(() => mockRepository.deleteWord(any(), userId: any(named: 'userId')))
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(const DeleteWordParams(id: testWordId, userId: testUserId));

      expect(result.isLeft(), true);
    });
  });
}
