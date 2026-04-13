import 'package:freezed_annotation/freezed_annotation.dart';

part 'lexicon_stats.freezed.dart';

@freezed
abstract class LexiconStats with _$LexiconStats {
  const factory LexiconStats({
    required int total,
    required int known,
    required int unknown,
  }) = _LexiconStats;

  const LexiconStats._();

  factory LexiconStats.empty() =>
      const LexiconStats(total: 0, known: 0, unknown: 0);
}
