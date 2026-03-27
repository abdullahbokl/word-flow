import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/script_processor.dart';
import '../entities/word.dart';
import '../repositories/word_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class SaveProcessedWords {
  final WordRepository _repository;

  SaveProcessedWords(this._repository);

  Future<Either<Failure, void>> call(List<ProcessedWord> processedWords, {String? userId}) async {
    try {
      // Isolate the mapping to avoid jank if the list is huge
      final words = await compute(_mapToWords, _MapParams(processedWords, userId));
      return await _repository.saveWords(words);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class _MapParams {
  final List<ProcessedWord> processed;
  final String? userId;
  _MapParams(this.processed, this.userId);
}

List<Word> _mapToWords(_MapParams params) {
  final now = DateTime.now().toUtc();
  const uuid = Uuid();
  return params.processed.map((e) => Word(
    id: uuid.v4(),
    userId: params.userId,
    wordText: e.wordText,
    totalCount: e.totalCount,
    isKnown: e.isKnown,
    lastUpdated: now,
  )).toList();
}
