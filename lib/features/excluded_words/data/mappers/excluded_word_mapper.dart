import 'package:lexitrack/core/database/app_database.dart';
import 'package:lexitrack/features/excluded_words/domain/entities/excluded_word.dart';

extension ExcludedWordRowMapper on ExcludedWordRow {
  ExcludedWord toEntity() {
    return ExcludedWord(
      id: id,
      word: word,
      createdAt: createdAt,
    );
  }
}

extension ExcludedWordEntityMapper on ExcludedWord {
  ExcludedWordsCompanion toCompanion() {
    return ExcludedWordsCompanion.insert(
      word: word,
      createdAt: createdAt,
    );
  }
}
