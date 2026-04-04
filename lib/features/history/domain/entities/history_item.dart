import 'package:equatable/equatable.dart';

class HistoryItem extends Equatable {
  const HistoryItem({
    required this.id,
    required this.title,
    required this.totalWords,
    required this.uniqueWords,
    required this.createdAt,
    required this.contentSnippet,
  });

  final int id;
  final String title;
  final int totalWords;
  final int uniqueWords;
  final DateTime createdAt;
  final String contentSnippet;

  @override
  List<Object?> get props => [id, title, totalWords, uniqueWords];
}
