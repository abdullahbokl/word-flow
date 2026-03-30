import 'package:equatable/equatable.dart';

/// Represents a group of related word forms that share a common stem.
/// Used to aggregate statistics and 'known' status for variants of the same root word.
class StemmedWordGroup extends Equatable {
  const StemmedWordGroup({
    required this.stemRoot,
    required this.variants,
    required this.totalCount,
    this.isKnown = false,
  });

  /// The common root (e.g., "run")
  final String stemRoot;

  /// Original word forms found in the text (e.g., ["run", "running", "runs"])
  final List<String> variants;

  /// The sum of occurrences of all variants.
  final int totalCount;

  /// True if the root or any variant is already marked as known.
  final bool isKnown;

  @override
  List<Object?> get props => [stemRoot, variants, totalCount, isKnown];
}
