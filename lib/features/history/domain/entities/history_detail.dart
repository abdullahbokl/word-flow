import 'package:equatable/equatable.dart';
import 'package:lexitrack/core/common/models/word_with_local_freq.dart';
import 'package:lexitrack/features/history/domain/entities/history_item.dart';

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
