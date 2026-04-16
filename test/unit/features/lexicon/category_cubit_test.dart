import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordflow/features/lexicon/domain/entities/tag_entity.dart';
import 'package:wordflow/features/lexicon/domain/repositories/category_repository.dart';
import 'package:wordflow/features/lexicon/presentation/cubit/category_cubit.dart';
import 'package:wordflow/features/lexicon/presentation/cubit/category_state.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late CategoryCubit cubit;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    cubit = CategoryCubit(categoryRepository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('CategoryCubit', () {
    final tags = [
      const TagEntity(id: 1, name: 'Tag 1'),
      const TagEntity(id: 2, name: 'Tag 2'),
    ];

    blocTest<CategoryCubit, CategoryState>(
      'loadTags emits [Loading, Loaded] when successful',
      build: () {
        when(() => mockRepository.watchCustomTags())
            .thenAnswer((_) => Stream.value(Right(tags)));
        return cubit;
      },
      act: (c) => c.loadTags(),
      expect: () => [
        const CategoryLoading(),
        CategoryLoaded(tags),
      ],
    );

    blocTest<CategoryCubit, CategoryState>(
      'addTag calls repository addCustomTag',
      build: () {
        when(() => mockRepository.addCustomTag(any()))
            .thenAnswer((_) => TaskEither.right(tags.first));
        return cubit;
      },
      act: (c) => c.addTag('New Tag'),
      verify: (_) {
        verify(() => mockRepository.addCustomTag('New Tag')).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'deleteTag calls repository deleteCustomTag',
      build: () {
        when(() => mockRepository.deleteCustomTag(any()))
            .thenAnswer((_) => TaskEither.right(unit));
        return cubit;
      },
      act: (c) => c.deleteTag(1),
      verify: (_) {
        verify(() => mockRepository.deleteCustomTag(1)).called(1);
      },
    );
  });
}
