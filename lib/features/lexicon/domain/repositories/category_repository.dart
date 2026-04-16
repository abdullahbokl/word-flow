import 'package:fpdart/fpdart.dart';
import 'package:wordflow/core/error/failures.dart';
import 'package:wordflow/features/lexicon/domain/entities/tag_entity.dart';

abstract interface class CategoryRepository {
  TaskEither<Failure, List<TagEntity>> getCustomTags();
  Stream<Either<Failure, List<TagEntity>>> watchCustomTags();
  TaskEither<Failure, TagEntity> addCustomTag(String name);
  TaskEither<Failure, Unit> deleteCustomTag(int tagId);
  TaskEither<Failure, Unit> assignTag(int wordId, int tagId);
  TaskEither<Failure, Unit> removeTag(int wordId, int tagId);
  TaskEither<Failure, List<TagEntity>> getWordTags(int wordId);
  Stream<Either<Failure, List<TagEntity>>> watchWordTags(int wordId);
}
