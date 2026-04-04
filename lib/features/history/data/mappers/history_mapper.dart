import '../../../../core/database/app_database.dart';
import '../../domain/entities/history_item.dart';

extension AnalyzedTextRowMapper on AnalyzedTextRow {
  HistoryItem toEntity() {
    return HistoryItem(
      id: id,
      title: title,
      totalWords: totalWords,
      uniqueWords: uniqueWords,
      createdAt: createdAt,
      contentSnippet: content.length > 100 ? '${content.substring(0, 100)}...' : content,
    );
  }
}
