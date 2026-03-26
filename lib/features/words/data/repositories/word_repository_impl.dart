import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/word_local_source.dart';
import '../models/word_model.dart';
import '../../../../core/utils/uuid_generator.dart';

@LazySingleton(as: WordRepository)
class WordRepositoryImpl implements WordRepository {
  final WordLocalSource _localSource;

  WordRepositoryImpl(this._localSource);

  @override
  Future<Either<Failure, void>> saveWords(List<Word> words) async {
    try {
      final models = words.map((e) => WordModel.fromEntity(e)).toList();
      await _localSource.saveWords(models);
      
      // Enqueue sync for each word
      for (final model in models) {
        if (model.userId != null) {
          await _localSource.enqueueSyncOperation(model.id, 'upsert');
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleKnown(String text, {String? userId}) async {
    try {
      final word = await _localSource.getWordByText(text, userId: userId);
      
      WordModel model;
      if (word != null) {
        model = WordModel.fromEntity(word.copyWith(
          isKnown: !word.isKnown,
          lastUpdated: DateTime.now().toUtc(),
        ));
      } else {
        // Create new word from scratch
        model = WordModel(
          id: UuidGenerator.generate(),
          userId: userId,
          wordText: text,
          totalCount: 1,
          isKnown: true, // If we're toggling it from "unknown" it becomes known
          lastUpdated: DateTime.now().toUtc(),
        );
      }
      
      await _localSource.saveWord(model);
      
      // Enqueue sync if moving to/staying in database
      if (model.userId != null) {
        await _localSource.enqueueSyncOperation(model.id, 'upsert');
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Word>>> getKnownWords({String? userId}) async {
    try {
      final words = await _localSource.getWords(userId: userId);
      return Right(words.where((e) => e.isKnown).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<Word>> watchWords({String? userId}) {
    return _localSource.watchWords(userId: userId).map((event) => event);
  }

  @override
  Future<Either<Failure, int>> adoptGuestWords(String userId) async {
    try {
      final count = await _localSource.adoptGuestWords(userId);
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalWords({String? userId}) async {
    try {
      await _localSource.clearLocalWords(userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
