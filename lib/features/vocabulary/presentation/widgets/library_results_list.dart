import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/add_edit_word_sheet.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_state.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/library_animated_item.dart';
import 'package:word_flow/core/widgets/empty_state.dart';

class LibraryResultsList extends StatelessWidget {
  const LibraryResultsList({
    super.key,
    required this.words,
    required this.filter,
    required this.searchQuery,
    required this.pendingWordIds,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<WordEntity> words;
  final WordsFilter filter;
  final String searchQuery;
  final Set<String> pendingWordIds;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty && searchQuery.isEmpty) {
      return EmptyState(
        key: const ValueKey('empty_none'),
        icon: Icons.library_books_outlined,
        title: 'No words yet',
        subtitle: 'Paste a script to get started',
        action: FilledButton(
          onPressed: () => context.go('/workspace'),
          child: const Text('Go to Workspace'),
        ),
      );
    }

    if (words.isEmpty) {
      return const EmptyState(
        key: ValueKey('empty_search'),
        icon: Icons.search_off,
        title: 'No matches',
        subtitle: 'Try a different search term or filter',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent * 0.8) {
          onLoadMore();
          return true;
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList.builder(
              itemCount: words.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= words.length) {
                  return const _LoadMoreFooter();
                }
                final item = words[index];
                return LibraryAnimatedItem(
                  key: ValueKey(item.id),
                  word: item,
                  isPending: pendingWordIds.contains(item.id),
                  onEdit: () => _showAddEditSheet(context, word: item),
                  onDelete: () => _confirmDelete(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditSheet(
    BuildContext outerContext, {
    required WordEntity word,
  }) {
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
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              outerContext.read<LibraryCubit>().deleteWord(
                word.id,
                userId: word.userId,
              );
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
