import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/word.dart';

part 'library_state.freezed.dart';

enum WordsFilter { all, known, unknown }

@freezed
class LibraryState with _$LibraryState {
  const factory LibraryState.initial() = _Initial;
  const factory LibraryState.loading() = _Loading;
  const factory LibraryState.loaded({
    required List<WordEntity> words,
    @Default(WordsFilter.all) WordsFilter filter,
    @Default('') String searchQuery,
    @Default(<String>{}) Set<String> pendingWordIds,
  }) = _Loaded;
  const factory LibraryState.error(String message) = _Error;
}
