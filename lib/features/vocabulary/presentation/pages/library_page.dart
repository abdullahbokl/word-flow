import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_state.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';
import 'package:word_flow/features/vocabulary/domain/entities/word_entity.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/add_edit_word_sheet.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/library_search_bar.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/library_filter_row.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/library_results_list.dart';
import 'package:word_flow/core/widgets/word_card_shimmer.dart';
import 'package:word_flow/core/widgets/error_state_widget.dart';
import 'package:word_flow/core/widgets/offline_banner_widget.dart';
import 'package:word_flow/core/errors/failure_mapper.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().currentUserId;
    return BlocProvider(
      create: (context) => getIt<LibraryCubit>()..init(userId),
      child: const LibraryView(),
    );
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
    final userId = context.read<AuthCubit>().currentUserId;
    return BlocListener<LibraryCubit, LibraryState>(
      listenWhen: (previous, current) {
        final previousError = previous.maybeMap(
          loaded: (s) => s.lastError,
          orElse: () => null,
        );
        final currentError = current.maybeMap(
          loaded: (s) => s.lastError,
          orElse: () => null,
        );
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
                idle: (count, lastSync, failure) => const SizedBox.shrink(),
                syncing: (count, failure) => const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (count, message, failure) => Padding(
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
        body: Column(
          children: [
            const OfflineBannerWidget(),
            _SyncErrorBanner(),
            Expanded(
              child: BlocBuilder<LibraryCubit, LibraryState>(
                buildWhen: (previous, current) =>
                    previous.runtimeType != current.runtimeType,
                builder: (context, state) => state.when(
                  initial: () => const Center(child: SizedBox.shrink()),
                  loading: () => const ShimmerList(),
                  loaded: (words, filter, query, pendingIds, error, failure) =>
                      _LibraryLoadedContent(
                        searchController: _searchController,
                        onClearSearch: () => _clearSearch(context),
                      ),
                  error: (message, failure) {
                    final isAuth = failure is AuthFailure;
                    return ErrorStateWidget(
                      title: failure?.title ?? 'Library Error',
                      message: failure?.friendlyMessage ?? message,
                      icon: failure?.icon ?? Icons.error_outline_rounded,
                      onRetry: isAuth
                          ? null
                          : () => context.read<LibraryCubit>().init(userId),
                      actionLabel: isAuth ? 'Sign In Again' : null,
                      onAction: isAuth
                          ? () => context.read<AuthCubit>().logOut()
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
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
    final userId = outerContext.read<AuthCubit>().currentUserId;
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      builder: (context) => AddEditWordSheet(
        word: word,
        onSave: (text, isKnown) {
          if (word == null) {
            outerContext.read<LibraryCubit>().addWord(
              text,
              isKnown,
              userId: userId,
            );
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
            onFilterChanged: (filter) =>
                context.read<LibraryCubit>().setFilter(filter),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child:
              BlocSelector<
                LibraryCubit,
                LibraryState,
                ({
                  List<WordEntity> words,
                  WordsFilter filter,
                  String searchQuery,
                  Set<String> pendingWordIds,
                })
              >(
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
                builder: (context, data) => RepaintBoundary(
                  child: LibraryResultsList(
                    words: data.words,
                    filter: data.filter,
                    searchQuery: data.searchQuery,
                    pendingWordIds: data.pendingWordIds,
                  ),
                ),
              ),
        ),
      ],
    );
  }
}

class _SyncErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        return state.maybeMap(
          error: (s) => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.sync_problem_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.failure?.friendlyMessage ?? s.message,
                    style: const TextStyle(fontSize: 13, color: Colors.orange),
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<SyncCubit>().syncNow(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
