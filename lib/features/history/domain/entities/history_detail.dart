import 'package:equatable/equatable.dart';
import '../../../lexicon/domain/entities/word_entity.dart';
import './history_item.dart';

class HistoryDetail extends Equatable {
  const HistoryDetail({
    required this.item,
    required this.words,
  });

  final HistoryItem item;
  final List<WordWithLocalFreq> words;

  @override
  List<Object?> get props => [item, words];
}

class WordWithLocalFreq extends Equatable {
  const WordWithLocalFreq({
    required this.word,
    required this.localFrequency,
  });

  final WordEntity word;
  final int localFrequency;

  @override
  List<Object?> get props => [word, localFrequency];
}
