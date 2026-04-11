import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lexitrack/features/excluded_words/domain/entities/excluded_word.dart';

part 'excluded_words_state.freezed.dart';

@freezed
class ExcludedWordsState with _$ExcludedWordsState {
  const factory ExcludedWordsState.initial() = _Initial;
  const factory ExcludedWordsState.loading() = _Loading;
  const factory ExcludedWordsState.loaded(List<ExcludedWord> words) = _Loaded;
  const factory ExcludedWordsState.error(String message) = _Error;
}
