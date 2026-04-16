import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:wordflow/core/constants/app_strings.dart';
import 'package:wordflow/core/domain/entities/word_entity.dart';
import 'package:wordflow/core/utils/ui_utils.dart';
import 'package:wordflow/core/widgets/app_empty_state.dart';
import 'package:wordflow/core/widgets/app_loader.dart';
import 'package:wordflow/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:wordflow/features/lexicon/presentation/widgets/word_card.dart';

class WordsSliverList extends StatelessWidget {
  const WordsSliverList({
    required this.words,
    required this.hasReachedMax,
    required this.onEdit,
    super.key,
  });

  final List<WordEntity> words;
  final bool hasReachedMax;
  final Function(WordEntity) onEdit;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyState(
          icon: Icons.menu_book_outlined,
          title: AppStrings.noWordsYet,
          subtitle: AppStrings.noWordsSubtitle,
        ),
      );
    }

    return MultiSliver(
      children: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final w = words[i];
              return RepaintBoundary(
                child: WordCard(
                  key: ValueKey(w.id),
                  word: w,
                  onToggle: () =>
                      ctx.read<LexiconBloc>().add(ToggleWordStatusEvent(w.id)),
                  onExclude: () =>
                      ctx.read<LexiconBloc>().add(ExcludeWordEvent(w.id)),
                  onDelete: () {
                    final wordText = w.text;
                    final previousId = w.id;
                    final previousFrequency = w.frequency;
                    final wasFullyDeleted = w.frequency <= 1;
                    ctx.read<LexiconBloc>().add(DeleteWordEvent(w.id));
                    AppUIUtils.showSnackBar(
                      ctx,
                      message: AppStrings.wordDeleted(wordText),
                      actionLabel: AppStrings.undo,
                      onAction: () =>
                          ctx.read<LexiconBloc>().add(RestoreWordEvent(
                                wordText,
                                previousId: previousId,
                                previousFrequency: previousFrequency,
                                wasFullyDeleted: wasFullyDeleted,
                              )),
                    );
                  },
                  onEdit: () => onEdit(w),
                  onAILookup: () {
                    // AI Lookup logic will be implemented in future tasks.
                    // For now, we just provide the callback.
                  },
                ),
              );
            },
            childCount: words.length,
          ),
        ),
        if (!hasReachedMax)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: AppLoader(),
            ),
          ),
      ],
    );
  }
}
