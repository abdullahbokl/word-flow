import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/database/write_queue.dart';
import 'package:word_flow/core/sync/sync_operation.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:word_flow/features/vocabulary/data/mappers/word_mapper.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/features/vocabulary/data/repositories/word_repository_impl_helpers.dart';

@LazySingleton(as: WordRepository)
class WordRepositoryImpl with WordRepositoryImplHelpers implements WordRepository {
  WordRepositoryImpl(this.localSource, this.syncSource, this.writeQueue, this.logger);

  @override final WordLocalSource localSource;
  @override final SyncLocalSource syncSource;
  @override final LocalWriteQueue writeQueue;
  @override final AppLogger logger;

  @override
  Future<Either<Failure, void>> saveWords(List<WordEntity> words) => handleSaveWords(words);

  @override
  Future<Either<Failure, List<String>>> getKnownWordTexts({String? userId}) async {
    try {
      return Right(await localSource.getKnownWordTexts(userId: userId));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleKnown(String text, {String? userId}) => handleToggleKnown(text, userId: userId);

  @override
  Future<Either<Failure, List<WordEntity>>> getKnownWords({String? userId}) async {
    try {
      final models = await localSource.getWords(userId: userId);
      return Right(models.where((e) => e.isKnown).map(WordMapper.toEntityFromModel).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<WordEntity>> watchWords({String? userId}) =>
      localSource.watchWords(userId: userId).map((ms) => ms.map(WordMapper.toEntityFromModel).toList());

  @override
  Future<Either<Failure, int>> adoptGuestWords(String userId) => handleAdoptGuestWords(userId);

  @override
  Future<Either<Failure, void>> clearLocalWords({String? userId}) => handleClearLocalWords(userId: userId);

  @override
  Future<Either<Failure, int>> getGuestWordsCount() => handleGetGuestWordsCount();

  @override
  Future<Either<Failure, void>> deleteWord(String id, {String? userId}) async {
    try {
      await writeQueue.enqueue(() async {
        await localSource.deleteWord(id);
        if (userId != null) await syncSource.enqueueSyncOperation(id, SyncOperation.delete.value);
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateWord(WordEntity word) async {
    try {
      await writeQueue.enqueue(() async {
        final model = WordMapper.fromEntityToModel(word);
        await localSource.saveWord(model);
        if (model.userId != null) await syncSource.enqueueSyncOperation(model.id, SyncOperation.upsert.value);
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
