import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:word_flow/features/words/presentation/widgets/add_edit_word_sheet.dart';
import 'package:word_flow/features/words/domain/entities/word.dart';
import 'package:word_flow/features/words/presentation/cubit/library_cubit.dart';
import 'package:word_flow/features/words/presentation/cubit/library_state.dart';
import 'package:word_flow/shared/widgets/word_card_base.dart';

class LibraryResultsList extends StatelessWidget {

  const LibraryResultsList({
    super.key,
    required this.words,
    required this.filter,
    required this.searchQuery,
    required this.pendingWordIds,
  });
  final List<WordEntity> words;
  final WordsFilter filter;
  final String searchQuery;
  final Set<String> pendingWordIds;

  @override
  Widget build(BuildContext context) {
    final filtered = words.where((w) {
      final matchesFilter = switch (filter) {
        WordsFilter.all => true,
        WordsFilter.known => w.isKnown,
        WordsFilter.unknown => !w.isKnown,
      };
      final matchesSearch = w.wordText.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList(growable: false);

    if (filtered.isEmpty) return const _EmptySearchResultsView();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final word = filtered[index];
        final isPending = pendingWordIds.contains(word.id);
        return WordCardBase(
          key: ValueKey(word.id),
          word: word,
          mode: WordCardMode.library,
          isPending: isPending,
          onEdit: () => _showAddEditSheet(context, word: word),
          onDelete: () => _confirmDelete(context, word),
        );
      },
    );
  }

  void _showAddEditSheet(BuildContext outerContext, {required WordEntity word}) {
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      builder: (context) => AddEditWordSheet(
        word: word,
        onSave: (text, isKnown) {
          outerContext.read<LibraryCubit>().updateWord(word, text, isKnown);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext outerContext, WordEntity word) {
    showDialog(
      context: outerContext,
      builder: (context) => AlertDialog(
        title: const Text('Delete word?'),
        content: Text('Are you sure you want to delete "${word.wordText}"?'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              outerContext.read<LibraryCubit>().deleteWord(word.id, userId: word.userId);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
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
