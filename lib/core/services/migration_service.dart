import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/adopt_guest_words.dart';

@lazySingleton
class MigrationService {
  MigrationService(this._wordRepository, this._adoptGuestWords, this._logger);

  final WordRepository _wordRepository;
  final AdoptGuestWords _adoptGuestWords;
  final AppLogger _logger;

  Future<Either<Failure, int>> migrateGuestData(String userId) async {
    _logger.debug('Migrating guest words for user: $userId');
    final result = await _adoptGuestWords(userId);
    return result.fold(
      (failure) {
        _logger.error('Failed to migrate guest data', failure);
        return Left(failure);
      },
      (count) {
        _logger.debug('Successfully migrated $count guest words');
        return Right(count);
      },
    );
  }

  Future<Either<Failure, void>> discardGuestData() async {
    _logger.debug('Discarding guest words');
    // Using userId: null discards words belonging to the guest.
    final result = await _wordRepository.clearLocalWords(userId: null);
    return result.fold(
      (failure) {
        _logger.error('Failed to discard guest data', failure);
        return Left(failure);
      },
      (_) {
        _logger.debug('Successfully discarded guest words');
        return const Right(null);
      },
    );
  }

  Future<Either<Failure, int>> getGuestWordsCount() async {
    return await _wordRepository.getGuestWordsCount();
  }
}
