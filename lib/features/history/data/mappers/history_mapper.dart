import 'package:lexitrack/core/database/app_database.dart';
import 'package:lexitrack/features/history/domain/entities/history_item.dart';

extension AnalyzedTextRowMapper on AnalyzedTextRow {
  HistoryItem toEntity() {
    return HistoryItem(
      id: id,
      title: title,
      totalWords: totalWords,
      uniqueWords: uniqueWords,
      knownWords: knownWords,
      unknownWords: unknownWords,
      createdAt: createdAt,
      contentSnippet: content.length > 100 ? '${content.substring(0, 100)}...' : content,
    );
  }
}
