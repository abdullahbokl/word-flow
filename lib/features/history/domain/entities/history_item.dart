import 'package:equatable/equatable.dart';

class HistoryItem extends Equatable {
  const HistoryItem({
    required this.id,
    required this.title,
    required this.totalWords,
    required this.uniqueWords,
    required this.createdAt,
    required this.contentSnippet,
    this.knownWords = 0,
    this.unknownWords = 0,
  });

  final int id;
  final String title;
  final int totalWords;
  final int uniqueWords;
  final int knownWords;
  final int unknownWords;
  final DateTime createdAt;
  final String contentSnippet;

  double get comprehension =>
      uniqueWords == 0 ? 100 : (knownWords / uniqueWords) * 100;

  @override
  List<Object?> get props => [
        id,
        title,
        totalWords,
        uniqueWords,
        knownWords,
        unknownWords,
        createdAt,
      ];
}
