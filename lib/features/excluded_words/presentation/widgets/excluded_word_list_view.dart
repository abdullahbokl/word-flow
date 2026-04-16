import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/theme/app_colors.dart';
import 'package:wordflow/core/theme/design_tokens.dart';
import 'package:wordflow/core/widgets/app_empty_state.dart';
import 'package:wordflow/core/widgets/app_error_widget.dart';
import 'package:wordflow/core/widgets/app_loader.dart';
import 'package:wordflow/core/widgets/app_text.dart';
import 'package:wordflow/features/excluded_words/presentation/cubit/excluded_words_cubit.dart';
import 'package:wordflow/features/excluded_words/presentation/cubit/excluded_words_state.dart';
import 'package:wordflow/features/excluded_words/presentation/widgets/excluded_word_form_dialog.dart';

class ExcludedWordListView extends StatelessWidget {
  const ExcludedWordListView({
    super.key,
    this.filter,
  });

  final List<String>? filter;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExcludedWordsCubit, ExcludedWordsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const AppLoader(),
          loading: () => const AppLoader(),
          error: (message) => AppErrorWidget(
            error: message,
            onRetry: () =>
                context.read<ExcludedWordsCubit>().loadExcludedWords(),
          ),
          loaded: (words) {
            final displayWords = filter != null
                ? words
                    .where((w) => filter!.contains(w.word.toLowerCase()))
                    .toList()
                : words;

            if (displayWords.isEmpty) {
              return const AppEmptyState(
                icon: Icons.block_rounded,
                title: 'No excluded words',
                subtitle: 'Add words that you want to ignore during analysis.',
              ).animate().fadeIn().scale(duration: AppTokens.durNormal);
            }

            return ListView.builder(
              itemCount: displayWords.length,
              padding: const EdgeInsets.only(bottom: AppTokens.space64),
              itemBuilder: (context, index) {
                final word = displayWords[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.space12),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTokens.defaultRadius),
                      side: BorderSide(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.1),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space4,
                      ),
                      title: AppText.body(
                        word.word,
                        fontWeight: FontWeight.w600,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => ExcludedWordFormDialog.show(
                                context,
                                word: word),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.restore_rounded,
                              size: 20,
                              color: AppColors.secondary,
                            ),
                            tooltip: 'Restore to Lexicon',
                            onPressed: () => context
                                .read<ExcludedWordsCubit>()
                                .deleteWord(word.id!),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: (index * 50).ms,
                        duration: AppTokens.durNormal,
                      )
                      .slideY(begin: 0.1, curve: Curves.easeOutQuad),
                );
              },
            );
          },
        );
      },
    );
  }
}
