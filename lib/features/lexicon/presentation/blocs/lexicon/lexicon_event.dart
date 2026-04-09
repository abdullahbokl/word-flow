import 'package:equatable/equatable.dart';

import '../../../domain/entities/lexicon_stats.dart';
import '../../../../../core/domain/entities/word_entity.dart';
import '../../../domain/entities/word_filter.dart';
import '../../../domain/entities/word_sort.dart';

sealed class LexiconEvent extends Equatable {
  const LexiconEvent();

  @override
  List<Object?> get props => [];
}

final class LoadLexicon extends LexiconEvent {
  const LoadLexicon();
}

final class LexiconUpdateReceived extends LexiconEvent {
  const LexiconUpdateReceived(this.words, [this.filter, this.sort, this.query]);
  final List<WordEntity> words;
  final WordFilter? filter;
  final WordSort? sort;
  final String? query;

  @override
  List<Object?> get props => [words, filter, sort, query];
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

final class UpdateWordEvent extends LexiconEvent {
  const UpdateWordEvent(
    this.wordId, {
    this.text,
    this.meaning,
    this.description,
    this.definitions,
    this.examples,
    this.translations,
    this.synonyms,
  });
  final int wordId;
  final String? text;
  final String? meaning;
  final String? description;
  final List<String>? definitions;
  final List<String>? examples;
  final List<String>? translations;
  final List<String>? synonyms;

  @override
  List<Object?> get props => [
        wordId,
        text,
        meaning,
        description,
        definitions,
        examples,
        translations,
        synonyms
      ];
}

final class SortLexicon extends LexiconEvent {
  const SortLexicon(this.sort);
  final WordSort sort;

  @override
  List<Object?> get props => [sort];
}

final class LoadMoreLexicon extends LexiconEvent {
  const LoadMoreLexicon();
}
