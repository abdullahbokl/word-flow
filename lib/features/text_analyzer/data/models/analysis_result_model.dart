import 'package:equatable/equatable.dart';

class WordWithLocalFreqModel extends Equatable {
  const WordWithLocalFreqModel({
    required this.id,
    required this.text,
    required this.frequency,
    required this.isKnown,
    required this.createdAt,
    required this.updatedAt,
    required this.localFrequency, this.meaning,
    this.description,
  });

  factory WordWithLocalFreqModel.fromMap(Map<String, Object?> map) {
    return WordWithLocalFreqModel(
      id: map['id'] as int,
      text: map['text'] as String,
      frequency: map['frequency'] as int,
      isKnown: map['isKnown'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAtMs'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAtMs'] as int),
      meaning: map['meaning'] as String?,
      description: map['description'] as String?,
      localFrequency: map['localFrequency'] as int,
    );
  }

  final int id;
  final String text;
  final int frequency;
  final bool isKnown;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? meaning;
  final String? description;
  final int localFrequency;

  @override
  List<Object?> get props => [
        id,
        text,
        frequency,
        isKnown,
        createdAt,
        updatedAt,
        meaning,
        description,
        localFrequency,
      ];
}

class AnalysisResultModel extends Equatable {
  const AnalysisResultModel({
    required this.id,
    required this.title,
    required this.totalWords,
    required this.uniqueWords,
    required this.unknownWords,
    required this.knownWords,
    required this.newWordsCount,
    required this.words,
    required this.excludedWordsFound,
  });

  factory AnalysisResultModel.fromMap(Map<String, Object?> map) {
    return AnalysisResultModel(
      id: map['id'] as int,
      title: map['title'] as String,
      totalWords: map['totalWords'] as int,
      uniqueWords: map['uniqueWords'] as int,
      unknownWords: map['unknownWords'] as int,
      knownWords: map['knownWords'] as int,
      newWordsCount: map['newWordsCount'] as int,
      words: (map['words'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(WordWithLocalFreqModel.fromMap)
          .toList(),
      excludedWordsFound: (map['excludedWordsFound'] as List<Object?>?)?.cast<String>() ?? [],
    );
  }

  final int id;
  final String title;
  final int totalWords;
  final int uniqueWords;
  final int unknownWords;
  final int knownWords;
  final int newWordsCount;
  final List<WordWithLocalFreqModel> words;
  final List<String> excludedWordsFound;

  @override
  List<Object?> get props => [
        id,
        title,
        totalWords,
        uniqueWords,
        unknownWords,
        knownWords,
        newWordsCount,
        words,
        excludedWordsFound,
      ];
}
