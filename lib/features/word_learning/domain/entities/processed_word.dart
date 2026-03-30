import 'package:equatable/equatable.dart';

class ProcessedWord extends Equatable {
  const ProcessedWord({
    required this.wordText,
    required this.totalCount,
    this.isKnown = false,
    this.variants = const [],
  });

  final String wordText;
  final int totalCount;
  final bool isKnown;
  final List<String> variants;

  @override
  List<Object?> get props => [wordText, totalCount, isKnown, variants];
}
