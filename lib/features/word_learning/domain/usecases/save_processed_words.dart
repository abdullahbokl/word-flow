import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class SaveProcessedWords {

  SaveProcessedWords(this._repository);
  final WordRepository _repository;

  Future<Either<Failure, void>> call(List<ProcessedWord> processedWords, {String? userId}) async {
    try {
     
      final words = await compute(_mapToWords, _MapParams(processedWords, userId));
      return await _repository.saveWords(words);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class _MapParams {
  _MapParams(this.processed, this.userId);
  final List<ProcessedWord> processed;
  final String? userId;
}

List<WordEntity> _mapToWords(_MapParams params) {
  final now = DateTime.now().toUtc();
  const uuid = Uuid();
  return params.processed.map((e) => WordEntity(
    id: uuid.v4(),
    userId: params.userId,
    wordText: e.wordText,
    totalCount: e.totalCount,
    isKnown: e.isKnown,
    lastUpdated: now,
  )).toList();
}
