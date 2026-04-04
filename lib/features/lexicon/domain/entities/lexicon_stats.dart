import 'package:equatable/equatable.dart';

class LexiconStats extends Equatable {
  const LexiconStats({
    required this.total,
    required this.known,
    required this.unknown,
  });

  const LexiconStats.empty() : total = 0, known = 0, unknown = 0;

  final int total;
  final int known;
  final int unknown;

  @override
  List<Object?> get props => [total, known, unknown];
}
