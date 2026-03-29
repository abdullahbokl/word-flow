import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/features/authentication/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_state.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/add_edit_word_sheet.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/library_search_bar.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/library_filter_row.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/library_results_list.dart';
import 'package:word_flow/shared/widgets/word_card_shimmer.dart';

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
    return BlocListener<LibraryCubit, LibraryState>(
      listenWhen: (previous, current) {
        final previousError = previous.maybeMap(loaded: (s) => s.lastError, orElse: () => null);
        final currentError = current.maybeMap(loaded: (s) => s.lastError, orElse: () => null);
        return currentError != null && currentError != previousError;
      },
      listener: (context, state) {
        state.maybeMap(
          loaded: (s) {
            if (s.lastError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(s.lastError!),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () => context.read<LibraryCubit>().clearError(),
                  ),
                ),
              );
              context.read<LibraryCubit>().clearError();
            }
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Words Library'),
          centerTitle: true,
          actions: [
            BlocBuilder<SyncCubit, SyncState>(
              builder: (context, state) => state.when(
                idle: (_, __) => const SizedBox.shrink(),
                syncing: (_) => const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, message) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.sync_problem, color: Colors.orange),
                    tooltip: message,
                    onPressed: () => context.read<SyncCubit>().syncNow(),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<LibraryCubit, LibraryState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
          builder: (context, state) => state.when(
            initial: () => const Center(child: SizedBox.shrink()),
            loading: () => const ShimmerList(),
            loaded: (_, __, ___, ____, _____) => _LibraryLoadedContent(
              searchController: _searchController,
              onClearSearch: () => _clearSearch(context),
            ),
            error: (message) => _LibraryErrorState(message: message),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEditSheet(context),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  void _clearSearch(BuildContext context) {
    _searchController.clear();
    context.read<LibraryCubit>().setSearch('');
  }

  void _showAddEditSheet(BuildContext outerContext, {WordEntity? word}) {
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
}

class _LibraryLoadedContent extends StatelessWidget {
  const _LibraryLoadedContent({
    required this.searchController,
    required this.onClearSearch,
  });

  final TextEditingController searchController;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LibrarySearchBar(
          controller: searchController,
          onChanged: (v) => context.read<LibraryCubit>().setSearch(v),
          onClear: onClearSearch,
        ),
        BlocSelector<LibraryCubit, LibraryState, WordsFilter>(
          selector: (state) => state.maybeMap(
            loaded: (s) => s.filter,
            orElse: () => WordsFilter.all,
          ),
          builder: (context, selectedFilter) => LibraryFilterRow(
            selectedFilter: selectedFilter,
            onFilterChanged: (filter) => context.read<LibraryCubit>().setFilter(filter),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocSelector<LibraryCubit, LibraryState, ({List<WordEntity> words, WordsFilter filter, String searchQuery, Set<String> pendingWordIds})>(
            selector: (state) => state.maybeMap(
              loaded: (s) => (
                words: s.words,
                filter: s.filter,
                searchQuery: s.searchQuery,
                pendingWordIds: s.pendingWordIds,
              ),
              orElse: () => (
                words: const <WordEntity>[],
                filter: WordsFilter.all,
                searchQuery: '',
                pendingWordIds: const <String>{},
              ),
            ),
            builder: (context, data) => LibraryResultsList(
              words: data.words,
              filter: data.filter,
              searchQuery: data.searchQuery,
              pendingWordIds: data.pendingWordIds,
            ),
          ),
        ),
      ],
    );
  }
}

class _LibraryErrorState extends StatelessWidget {
  const _LibraryErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Error: $message', style: const TextStyle(color: Colors.red)),
    );
  }
}
