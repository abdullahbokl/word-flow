import 'package:flutter/material.dart';
import 'package:word_flow/core/widgets/word_card_base.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';

class WordResultsAnimatedItem extends StatelessWidget {
  const WordResultsAnimatedItem({
    super.key,
    required this.animation,
    required this.word,
    required this.isPending,
    required this.isLast,
    this.enabled = true,
  });
  final Animation<double> animation;
  final ProcessedWord word;
  final bool isPending;
  final bool isLast;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-0.4, 0), // Moderate slide from left
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: SizeTransition(
          sizeFactor: curvedAnimation,
          axisAlignment: -1,
          child: Padding(
            key: ValueKey('item_${word.wordText}'),
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: WordCardBase(
              key: ValueKey('card_${word.wordText}'),
              word: word,
              mode: WordCardMode.workspace,
              isPending: isPending,
              enabled: enabled,
            ),
          ),
        ),
      ),
    );
  }
}
