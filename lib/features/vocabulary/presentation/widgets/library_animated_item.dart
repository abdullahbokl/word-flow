import 'package:flutter/material.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/shared/widgets/word_card_base.dart';

class LibraryAnimatedItem extends StatelessWidget {
  const LibraryAnimatedItem({
    super.key,
    required this.animation,
    required this.word,
    required this.isPending,
    this.onEdit,
    this.onDelete,
    this.enabled = true,
  });

  final Animation<double> animation;
  final WordEntity word;
  final bool isPending;
  final bool enabled;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    // Smoother curve for entry/exit
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.2, 0), // Pronounced slide from right
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: SizeTransition(
          sizeFactor: curvedAnimation,
          axisAlignment: 0.0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: WordCardBase(
              key: ValueKey('card_${word.id}'),
              word: word,
              mode: WordCardMode.library,
              isPending: isPending,
              enabled: enabled,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ),
      ),
    );
  }
}
