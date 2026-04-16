import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/lexicon/data/datasources/category_local_ds.dart';
import 'package:wordflow/features/lexicon/data/mappers/tag_row_mapper.dart';
import 'package:wordflow/features/lexicon/domain/entities/tag_entity.dart';
import 'package:wordflow/features/lexicon/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._local);

  final CategoryLocalDataSource _local;

  @override
  TaskEither<Failure, List<TagEntity>> getCustomTags() => TaskEither.tryCatch(
        () async {
          final rows = await _local.getCustomTags();
          return rows.toEntities();
        },
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  Stream<Either<Failure, List<TagEntity>>> watchCustomTags() =>
      _local.watchCustomTags().map((rows) => Right(rows.toEntities()));

  @override
  TaskEither<Failure, TagEntity> addCustomTag(String name) =>
      TaskEither.tryCatch(
        () async {
          final row = await _local.addCustomTag(name);
          return row.toEntity();
        },
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, Unit> deleteCustomTag(int tagId) => TaskEither.tryCatch(
        () async {
          await _local.deleteCustomTag(tagId);
          return unit;
        },
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, Unit> assignTag(int wordId, int tagId) =>
      TaskEither.tryCatch(
        () async {
          await _local.assignTag(wordId, tagId);
          return unit;
        },
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, Unit> removeTag(int wordId, int tagId) =>
      TaskEither.tryCatch(
        () async {
          await _local.removeTag(wordId, tagId);
          return unit;
        },
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  TaskEither<Failure, List<TagEntity>> getWordTags(int wordId) =>
      TaskEither.tryCatch(
        () async {
          final rows = await _local.getWordTags(wordId);
          return rows.toEntities();
        },
        (error, stack) => DatabaseFailure('$error', stack),
      );

  @override
  Stream<Either<Failure, List<TagEntity>>> watchWordTags(int wordId) =>
      _local.watchWordTags(wordId).map((rows) => Right(rows.toEntities()));
}
