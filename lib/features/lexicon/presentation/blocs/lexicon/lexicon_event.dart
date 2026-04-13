import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_filter.dart';
import 'package:wordflow/features/lexicon/domain/entities/word_sort.dart';

part 'lexicon_event.freezed.dart';

@freezed
abstract class LexiconEvent with _$LexiconEvent {
  const factory LexiconEvent.load() = LoadLexicon;
  const factory LexiconEvent.updateReceived({
    required List<WordEntity> words,
    WordFilter? filter,
    WordSort? sort,
    String? query,
  }) = LexiconUpdateReceived;
  const factory LexiconEvent.statsUpdateReceived(LexiconStats stats) =
      LexiconStatsUpdateReceived;
  const factory LexiconEvent.errorReceived(String message) =
      LexiconErrorReceived;
  const factory LexiconEvent.toggleStatus(int wordId) = ToggleWordStatusEvent;
  const factory LexiconEvent.delete(int wordId) = DeleteWordEvent;
  const factory LexiconEvent.restore(
    String text, {
    required int previousId,
    required int previousFrequency,
    required bool wasFullyDeleted,
  }) = RestoreWordEvent;
  const factory LexiconEvent.search(String query) = SearchLexicon;
  const factory LexiconEvent.filter(WordFilter filter) = FilterLexicon;
  const factory LexiconEvent.addManually(String word) = AddWordManuallyEvent;
  const factory LexiconEvent.update(
    int wordId, {
    String? text,
    String? meaning,
    String? description,
    List<String>? definitions,
    List<String>? examples,
    List<String>? translations,
    List<String>? synonyms,
  }) = UpdateWordEvent;
  const factory LexiconEvent.sort(WordSort sort) = SortLexicon;
  const factory LexiconEvent.fetchMore() = FetchMoreLexicon;
}
