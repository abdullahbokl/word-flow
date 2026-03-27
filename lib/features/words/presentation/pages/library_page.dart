import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/library_cubit.dart';
import '../cubit/library_state.dart';
import '../../domain/entities/word.dart';
import '../widgets/add_edit_word_sheet.dart';
import '../widgets/library_search_bar.dart';
import '../widgets/library_filter_row.dart';
import '../widgets/library_results_list.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.maybeMap(authenticated: (s) => s.user.id, orElse: () => null);
    return BlocProvider(create: (context) => getIt<LibraryCubit>()..init(userId), child: const LibraryView());
  }
}

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});
  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Words Library'), centerTitle: true),
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) => Column(
          children: [
            LibrarySearchBar(
              controller: _searchController,
              onChanged: (v) => context.read<LibraryCubit>().setSearch(v),
              onClear: () => _clearSearch(context),
            ),
            LibraryFilterRow(
              selectedFilter: state.maybeMap(loaded: (s) => s.filter, orElse: () => WordsFilter.all),
              onFilterChanged: (f) => context.read<LibraryCubit>().setFilter(f),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LibraryResultsList(
                state: state,
                onDelete: (w) => _confirmDelete(context, w),
                onEdit: (w) => _showAddEditSheet(context, word: w),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _clearSearch(BuildContext context) {
    _searchController.clear();
    context.read<LibraryCubit>().setSearch('');
  }

  void _showAddEditSheet(BuildContext outerContext, {Word? word}) {
    final userId = outerContext.read<AuthCubit>().state.maybeMap(authenticated: (s) => s.user.id, orElse: () => null);
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      builder: (context) => AddEditWordSheet(
        word: word,
        onSave: (text, isKnown) {
          if (word == null) {
            outerContext.read<LibraryCubit>().addWord(text, isKnown, userId: userId);
          } else {
            outerContext.read<LibraryCubit>().updateWord(word, text, isKnown);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext outerContext, Word word) {
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
