import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/database/write_queue.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/word_local_source.dart';
import '../datasources/sync_local_source.dart';
import '../models/word_model.dart';
import '../mappers/word_mapper.dart';
import '../../../../core/utils/uuid_generator.dart';

@LazySingleton(as: WordRepository)
class WordRepositoryImpl implements WordRepository {
  final WordLocalSource _localSource;
  final SyncLocalSource _syncSource;
  final LocalWriteQueue _writeQueue;

  WordRepositoryImpl(this._localSource, this._syncSource, this._writeQueue);

  Future<Either<Failure, T>> _try<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveWords(List<WordEntity> words) => _try(() async {
    await _writeQueue.enqueue(() async {
      final now = DateTime.now().toUtc();
      final List<WordModel> models = [];
      for (final word in words) {
        final candidate = WordMapper.fromEntityToModel(word);
        final existing = await _localSource.getWordByText(
          candidate.wordText,
          userId: candidate.userId,
        );
        if (existing == null) {
          models.add(WordModel(
            id: candidate.id,
            userId: candidate.userId,
            wordText: candidate.wordText,
            totalCount: candidate.totalCount,
            isKnown: candidate.isKnown,
            lastUpdated: now,
          ));
          continue;
        }

        models.add(WordModel(
          id: existing.id,
          userId: existing.userId,
          wordText: existing.wordText,
          totalCount: existing.totalCount + candidate.totalCount,
          isKnown: existing.isKnown || candidate.isKnown,
          lastUpdated: now,
        ));
      }
      await _localSource.saveWords(models);
      for (final model in models) {
        if (model.userId != null) {
          await _syncSource.enqueueSyncOperation(model.id, 'upsert');
        }
      }
    });
  });

  @override
  Future<Either<Failure, List<String>>> getKnownWordTexts({String? userId}) => 
    _try(() => _localSource.getKnownWordTexts(userId: userId));

  @override
  Future<Either<Failure, void>> toggleKnown(String text, {String? userId}) => _try(() async {
    await _writeQueue.enqueue(() async {
      final wordModel = await _localSource.getWordByText(text, userId: userId);
      final model = wordModel != null
          ? WordMapper.fromEntityToModel(
              WordMapper.toEntityFromModel(wordModel).copyWith(
                isKnown: !wordModel.isKnown,
                lastUpdated: DateTime.now().toUtc(),
              ),
            )
          : WordModel(
              id: UuidGenerator.generate(),
              userId: userId,
              wordText: text,
              totalCount: 1,
              isKnown: true,
              lastUpdated: DateTime.now().toUtc(),
            );
      await _localSource.saveWord(model);
      if (model.userId != null) {
        await _syncSource.enqueueSyncOperation(model.id, 'upsert');
      }
    });
  });

  @override
  Future<Either<Failure, List<WordEntity>>> getKnownWords({String? userId}) => 
    _try(() async {
      final models = await _localSource.getWords(userId: userId);
      return models
          .where((e) => e.isKnown)
          .map(WordMapper.toEntityFromModel)
          .toList();
    });

  @override
  Stream<List<WordEntity>> watchWords({String? userId}) {
    return _localSource.watchWords(userId: userId).map(
          (models) => models.map(WordMapper.toEntityFromModel).toList(),
        );
  }

  @override
  Future<Either<Failure, int>> adoptGuestWords(String userId) => 
    _try(() => _localSource.adoptGuestWords(userId));

  @override
  Future<Either<Failure, void>> clearLocalWords({String? userId}) => 
    _try(() => _localSource.clearLocalWords(userId: userId));

  @override
  Future<Either<Failure, int>> getGuestWordsCount() => 
    _try(() => _localSource.getGuestWordsCount());

  @override
  Future<Either<Failure, void>> deleteWord(String id, {String? userId}) => _try(() async {
    await _writeQueue.enqueue(() async {
      await _localSource.deleteWord(id);
      if (userId != null) await _syncSource.enqueueSyncOperation(id, 'delete');
    });
  });

  @override
  Future<Either<Failure, void>> updateWord(WordEntity word) => _try(() async {
    await _writeQueue.enqueue(() async {
      final model = WordMapper.fromEntityToModel(word);
      await _localSource.saveWord(model);
      if (model.userId != null) {
        await _syncSource.enqueueSyncOperation(model.id, 'upsert');
      }
    });
  });
}
