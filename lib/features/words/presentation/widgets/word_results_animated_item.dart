import 'package:flutter/material.dart';
import 'package:word_flow/core/widgets/word_card.dart';
import 'package:word_flow/features/words/domain/entities/processed_word.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/auth/presentation/cubit/auth_cubit.dart';

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
      curve: Curves.easeInOutCubic,
    );

    return SlideTransition(
     
     
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
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
            child: WordCard(
              key: ValueKey('card_${word.wordText}'),
              text: word.wordText,
              count: word.totalCount,
              isKnown: word.isKnown,
              isPending: isPending,
              onToggle: enabled
                  ? () {
                      final userId = context.read<AuthCubit>().state.maybeMap(
                            authenticated: (s) => s.user.id,
                            orElse: () => null,
                          );
                      context.read<WorkspaceCubit>().toggleKnown(word.wordText, userId: userId);
                    }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
