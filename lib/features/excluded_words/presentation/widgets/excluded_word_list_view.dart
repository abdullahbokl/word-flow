import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/widgets/app_empty_state.dart';
import 'package:wordflow/core/widgets/app_error_widget.dart';
import 'package:wordflow/core/widgets/app_loader.dart';
import 'package:wordflow/core/widgets/app_text.dart';
import 'package:wordflow/features/excluded_words/presentation/cubit/excluded_words_cubit.dart';
import 'package:wordflow/features/excluded_words/presentation/cubit/excluded_words_state.dart';
import 'excluded_word_form_dialog.dart';

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
            onRetry: () => context.read<ExcludedWordsCubit>().loadExcludedWords(),
          ),
          loaded: (words) {
            final displayWords = filter != null
                ? words.where((w) => filter!.contains(w.word.toLowerCase())).toList()
                : words;

            if (displayWords.isEmpty) {
              return const AppEmptyState(
                icon: Icons.block,
                title: 'No excluded words',
                subtitle: 'Add words that you want to ignore during analysis.',
              );
            }
            return ListView.separated(
              itemCount: displayWords.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final word = displayWords[index];
                return ListTile(
                  title: AppText.body(word.word),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => ExcludedWordFormDialog.show(context, word: word),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        onPressed: () => context.read<ExcludedWordsCubit>().deleteWord(word.id!),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
