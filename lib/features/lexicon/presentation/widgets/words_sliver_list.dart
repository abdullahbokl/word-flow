import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexitrack/core/constants/app_strings.dart';
import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/widgets/app_empty_state.dart';
import 'package:lexitrack/core/widgets/app_loader.dart';
import 'package:lexitrack/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:lexitrack/features/lexicon/presentation/widgets/word_tile.dart';
import 'package:sliver_tools/sliver_tools.dart';

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
              return WordTile(
                key: ValueKey(w.id),
                word: w,
                onToggle: () =>
                    ctx.read<LexiconBloc>().add(ToggleWordStatusEvent(w.id)),
                onDelete: () {
                  final wordText = w.text;
                  ctx.read<LexiconBloc>().add(DeleteWordEvent(w.id));
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.wordDeleted(wordText)),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: AppStrings.undo,
                        onPressed: () => ctx
                            .read<LexiconBloc>()
                            .add(AddWordManuallyEvent(wordText)),
                      ),
                    ),
                  );
                },
                onEdit: () => onEdit(w),
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
