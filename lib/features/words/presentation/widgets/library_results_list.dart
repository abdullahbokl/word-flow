import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/word_card.dart';
import '../../domain/entities/word.dart';
import '../cubit/library_cubit.dart';
import '../cubit/library_state.dart';

class LibraryResultsList extends StatelessWidget {
  final LibraryState state;
  final Function(WordEntity) onDelete;
  final Function(WordEntity) onEdit;

  const LibraryResultsList({
    super.key,
    required this.state,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      initial: () => const _LoadingView(),
      loading: () => const _LoadingView(),
      error: (msg) => _ErrorView(message: msg),
      loaded: (words, filter, searchQuery, pendingWordIds) {
        final filtered = words.where((w) {
          final matchesFilter = switch (filter) {
            WordsFilter.all => true,
            WordsFilter.known => w.isKnown,
            WordsFilter.unknown => !w.isKnown,
          };
          final matchesSearch = w.wordText.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesFilter && matchesSearch;
        }).toList();

        if (filtered.isEmpty) return const _EmptySearchResultsView();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final word = filtered[index];
            final isPending = pendingWordIds.contains(word.id);
            return WordCard(
              key: ValueKey(word.id),
              text: word.wordText,
              count: word.totalCount,
              isKnown: word.isKnown,
              isPending: isPending,
              onToggle: () => context.read<LibraryCubit>().toggleKnown(word),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  onPressed: isPending ? null : () => onEdit(word),
                  tooltip: 'Edit word',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 20, color: Theme.of(context).colorScheme.error),
                  onPressed: isPending ? null : () => onDelete(word),
                  tooltip: 'Delete word',
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(child: AppLoader());
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Text('Error: $message', style: const TextStyle(color: Colors.red)));
}

class _EmptySearchResultsView extends StatelessWidget {
  const _EmptySearchResultsView();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: scheme.secondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No words found.', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
