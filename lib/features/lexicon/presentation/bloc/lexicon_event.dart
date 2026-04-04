import 'package:equatable/equatable.dart';

import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';

sealed class LexiconEvent extends Equatable {
  const LexiconEvent();

  @override
  List<Object?> get props => [];
}

final class LoadLexicon extends LexiconEvent {
  const LoadLexicon();
}

final class LexiconUpdateReceived extends LexiconEvent {
  const LexiconUpdateReceived(this.words);
  final List<WordEntity> words;

  @override
  List<Object?> get props => [words];
}

final class LexiconStatsUpdateReceived extends LexiconEvent {
  const LexiconStatsUpdateReceived(this.stats);
  final LexiconStats stats;

  @override
  List<Object?> get props => [stats];
}

final class LexiconErrorReceived extends LexiconEvent {
  const LexiconErrorReceived(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class ToggleWordStatusEvent extends LexiconEvent {
  const ToggleWordStatusEvent(this.wordId);
  final int wordId;

  @override
  List<Object?> get props => [wordId];
}

final class DeleteWordEvent extends LexiconEvent {
  const DeleteWordEvent(this.wordId);
  final int wordId;

  @override
  List<Object?> get props => [wordId];
}

final class SearchLexicon extends LexiconEvent {
  const SearchLexicon(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class FilterLexicon extends LexiconEvent {
  const FilterLexicon(this.filter);
  final WordFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class AddWordManuallyEvent extends LexiconEvent {
  const AddWordManuallyEvent(this.word);
  final String word;

  @override
  List<Object?> get props => [word];
}

final class SortLexicon extends LexiconEvent {
  const SortLexicon(this.sort);
  final WordSort sort;

  @override
  List<Object?> get props => [sort];
}
