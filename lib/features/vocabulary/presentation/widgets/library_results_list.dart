import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/add_edit_word_sheet.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_state.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/library_animated_item.dart';
import 'package:word_flow/shared/widgets/empty_state.dart';

class LibraryResultsList extends StatefulWidget {
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
  State<LibraryResultsList> createState() => _LibraryResultsListState();
}

class _LibraryResultsListState extends State<LibraryResultsList> {
  static const _exitDuration = Duration(milliseconds: 450);
  static const _insertDuration = Duration(milliseconds: 400);

  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<WordEntity> _visibleItems;

  @override
  void initState() {
    super.initState();
    _visibleItems = _computeFilteredItems();
  }

  List<WordEntity> _computeFilteredItems() {
    return widget.words.where((w) {
      final matchesFilter = switch (widget.filter) {
        WordsFilter.all => true,
        WordsFilter.known => w.isKnown,
        WordsFilter.unknown => !w.isKnown,
      };
      final matchesSearch = w.wordText.toLowerCase().contains(
        widget.searchQuery.toLowerCase(),
      );
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  void didUpdateWidget(covariant LibraryResultsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetItems = _computeFilteredItems();

    // Check for "hard reset" (e.g. search changed or list length changed drastically)
    // For small changes, animate. For large ones, just rebuild.
    if (widget.searchQuery != oldWidget.searchQuery ||
        widget.filter != oldWidget.filter ||
        (targetItems.length - _visibleItems.length).abs() > 3) {
      setState(() {
        _listKey = GlobalKey<AnimatedListState>();
        _visibleItems = targetItems;
      });
      return;
    }

    final oldSet = _visibleItems.toSet();
    final newSet = targetItems.toSet();

    // Handle removals
    final toRemove = _visibleItems
        .where((item) => !newSet.contains(item))
        .toList();
    for (final item in toRemove) {
      final index = _visibleItems.indexOf(item);
      if (index != -1) {
        _removeItem(index, item);
      }
    }

    // Handle insertions
    final toAdd = targetItems.where((item) => !oldSet.contains(item)).toList();
    for (final item in toAdd) {
      final targetIndex = targetItems.indexOf(item);
      _insertItem(targetIndex, item);
    }
  }

  void _removeItem(int index, WordEntity item) {
    _visibleItems.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => LibraryAnimatedItem(
        animation: animation,
        word: item,
        isPending: widget.pendingWordIds.contains(item.id),
      ),
      duration: _exitDuration,
    );
  }

  void _insertItem(int index, WordEntity item) {
    // Ensure index is valid for current visible state
    final safeIndex = index > _visibleItems.length
        ? _visibleItems.length
        : index;
    _visibleItems.insert(safeIndex, item);
    _listKey.currentState?.insertItem(safeIndex, duration: _insertDuration);
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (widget.words.isEmpty && widget.searchQuery.isEmpty) {
      content = EmptyState(
        key: const ValueKey('empty_none'),
        icon: Icons.library_books_outlined,
        title: 'No words yet',
        subtitle: 'Paste a script to get started',
        action: FilledButton(
          onPressed: () => context.go('/workspace'),
          child: const Text('Go to Workspace'),
        ),
      );
    } else if (_visibleItems.isEmpty) {
      content = const EmptyState(
        key: ValueKey('empty_search'),
        icon: Icons.search_off,
        title: 'No matches',
        subtitle: 'Try a different search term or filter',
      );
    } else {
      content = AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        initialItemCount: _visibleItems.length,
        itemBuilder: (context, index, animation) {
          if (index >= _visibleItems.length) return const SizedBox.shrink();
          final item = _visibleItems[index];
          return LibraryAnimatedItem(
            key: ValueKey(item.id),
            animation: animation,
            word: item,
            isPending: widget.pendingWordIds.contains(item.id),
            onEdit: () => _showAddEditSheet(context, word: item),
            onDelete: () => _confirmDelete(context, item),
          );
        },
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: content,
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
