import 'package:freezed_annotation/freezed_annotation.dart';

part 'word.freezed.dart';

@freezed
class Word with _$Word {
  const factory Word({
    required String id,
    required String wordText,
    @Default(1) int totalCount,
    @Default(false) bool isKnown,
    required DateTime lastUpdated,
  }) = _Word;
}
