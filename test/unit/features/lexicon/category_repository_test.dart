import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/data/datasources/category_local_ds.dart';
import 'package:wordflow/features/lexicon/data/repositories/category_repository_impl.dart';
import 'package:wordflow/features/lexicon/domain/entities/tag_entity.dart';

class MockCategoryLocalDataSource extends Mock
    implements CategoryLocalDataSource {}

void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockCategoryLocalDataSource();
    repository = CategoryRepositoryImpl(mockDataSource);
  });

  group('CategoryRepositoryImpl', () {
    test('getCustomTags returns list of TagEntity', () async {
      final rows = [
        const CustomTagRow(id: 1, name: 'Tag 1'),
        const CustomTagRow(id: 2, name: 'Tag 2'),
      ];
      when(() => mockDataSource.getCustomTags()).thenAnswer((_) async => rows);

      final result = await repository.getCustomTags().run();

      result.fold(
        (l) => fail('Should not return failure'),
        (r) {
          expect(r.length, 2);
          expect(r[0], const TagEntity(id: 1, name: 'Tag 1'));
          expect(r[1], const TagEntity(id: 2, name: 'Tag 2'));
        },
      );
    });

    test('addCustomTag returns TagEntity', () async {
      const row = CustomTagRow(id: 1, name: 'New Tag');
      when(() => mockDataSource.addCustomTag(any()))
          .thenAnswer((_) async => row);

      final result = await repository.addCustomTag('New Tag').run();

      result.fold(
        (l) => fail('Should not return failure'),
        (r) {
          expect(r, const TagEntity(id: 1, name: 'New Tag'));
        },
      );
    });

    test('watchCustomTags emits mapped entities', () async {
      final rows = [const CustomTagRow(id: 1, name: 'Tag 1')];
      when(() => mockDataSource.watchCustomTags())
          .thenAnswer((_) => Stream.value(rows));

      final stream = repository.watchCustomTags();

      expect(
        stream,
        emits(isA<Right<dynamic, List<TagEntity>>>().having(
          (r) => r.value,
          'value',
          [const TagEntity(id: 1, name: 'Tag 1')],
        )),
      );
    });

    test('assignTag calls dataSource assignTag', () async {
      when(() => mockDataSource.assignTag(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.assignTag(1, 2).run();

      expect(result.isRight(), isTrue);
      verify(() => mockDataSource.assignTag(1, 2)).called(1);
    });

    test('removeTag calls dataSource removeTag', () async {
      when(() => mockDataSource.removeTag(any(), any()))
          .thenAnswer((_) async {});

      final result = await repository.removeTag(1, 2).run();

      expect(result.isRight(), isTrue);
      verify(() => mockDataSource.removeTag(1, 2)).called(1);
    });
  });
}
