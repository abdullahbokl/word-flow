import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/features/excluded_words/domain/entities/excluded_word.dart';

extension WordEntityToExcludedMapper on WordEntity {
  ExcludedWord toExcludedWord() {
    return ExcludedWord(
      id: id,
      word: text,
      createdAt: createdAt,
    );
  }
}
