import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
// import '../../../../core/common/state/bloc_status.dart'; // Removed as it became unused after refactor
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/sliver_status_view.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_text.dart';
import '../../domain/entities/lexicon_stats.dart';
import '../../domain/entities/word_filter.dart';
import '../../domain/entities/word_sort.dart';
import '../bloc/lexicon_bloc.dart';
import '../bloc/lexicon_event.dart';
import '../bloc/lexicon_state.dart';
import '../widgets/word_filter_bar.dart';
import '../widgets/word_tile.dart';
import '../widgets/lexicon_stats_header.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/word_entity.dart';

class LexiconPage extends StatefulWidget {
  const LexiconPage({super.key});

  @override
  State<LexiconPage> createState() => _LexiconPageState();
}

class _LexiconPageState extends State<LexiconPage> with AutomaticKeepAliveClientMixin {
  final _addCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _listScrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = context.read<LexiconBloc>().state.query;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _addCtrl.dispose();
    _searchCtrl.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      final bloc = context.read<LexiconBloc>();
      if (query == bloc.state.query) return;
      bloc.add(SearchLexicon(query));
    });
  }

  void _onAddWord() {
    _addCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText.title(AppStrings.addWord),
        content: AppTextField(
          controller: _addCtrl,
          autofocus: true,
          hint: AppStrings.enterWord,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _onAddSubmitted(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText.body(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: _onAddSubmitted,
            child: const AppText.body(AppStrings.add),
          ),
        ],
      ),
    );
  }

  void _onAddSubmitted() {
    final word = _addCtrl.text.trim();
    if (word.isNotEmpty) {
      context.read<LexiconBloc>().add(AddWordManuallyEvent(word));
    }
    Navigator.pop(context);
  }

  void _onEditWord(WordEntity word) {
    _addCtrl.text = word.text;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText.title(AppStrings.editWord),
        content: AppTextField(
          controller: _addCtrl,
          autofocus: true,
          hint: AppStrings.enterWord,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _onEditSubmitted(word),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText.body(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => _onEditSubmitted(word),
            child: const AppText.body(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _onEditSubmitted(WordEntity word) {
    final text = _addCtrl.text.trim();
    if (text.isNotEmpty && text != word.text) {
      // Assuming UpdateWordEvent updates the meaning for now based on the event definition
      // If we need to update text, we'd need to update the event/bloc.
      context.read<LexiconBloc>().add(UpdateWordEvent(word.id, meaning: text));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddWord,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocBuilder<LexiconBloc, LexiconState>(
          builder: (context, state) {
            return CustomScrollView(
              controller: _listScrollController,
              key: const PageStorageKey<String>('lexicon_scroll_view'),
              slivers: [
                const SliverToBoxAdapter(
                  child: PageHeader(title: AppStrings.myLexicon),
                ),
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: false,
                  elevation: 1,
                  toolbarHeight: 0,
                  expandedHeight: 215,
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _LexiconToolbar(
                      stats: state.stats,
                      searchCtrl: _searchCtrl,
                      filter: state.filter,
                      sort: state.sort,
                      onSearchChanged: _onSearchChanged,
                    ),
                  ),
                ),
                SliverStatusView<List<WordEntity>>(
                  status: state.status,
                  animate: false,
                  onInitial: () => const SliverFillRemaining(
                    child: AppLoader(message: AppStrings.loadingLexicon),
                  ),
                  onSuccess: (words) => _WordsSliverList(
                    words: words,
                    onEdit: _onEditWord,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LexiconToolbar extends StatelessWidget {
  const _LexiconToolbar({
    required this.stats,
    required this.searchCtrl,
    required this.filter,
    required this.sort,
    required this.onSearchChanged,
  });

  final LexiconStats stats;
  final TextEditingController searchCtrl;
  final WordFilter filter;
  final WordSort sort;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LexiconStatsHeader(stats: stats),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppTextField(
            controller: searchCtrl,
            hint: AppStrings.searchWords,
            prefixIcon: Icons.search,
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: WordFilterBar(
            active: filter,
            onChanged: (f) => context.read<LexiconBloc>().add(FilterLexicon(f)),
            activeSort: sort,
            onSortChanged: (s) =>
                context.read<LexiconBloc>().add(SortLexicon(s)),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _WordsSliverList extends StatelessWidget {
  const _WordsSliverList({
    required this.words,
    required this.onEdit,
  });

  final List<WordEntity> words;
  final Function(WordEntity) onEdit;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyState(
          icon: Icons.menu_book_outlined,
          title: 'No words yet',
          subtitle: 'Analyze a text to populate your lexicon.',
        ),
      );
    }

    return SliverPrototypeExtentList(
      prototypeItem: WordTile(
        word: WordEntity(
          id: -1,
          text: 'Prototype',
          frequency: 0,
          isKnown: false,
          meaning: 'A prototype for height calculation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        onToggle: () {},
        onDelete: () {},
        onEdit: () {},
      ),
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
                  content: Text('Deleted "$wordText"'),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      ctx.read<LexiconBloc>().add(AddWordManuallyEvent(wordText));
                    },
                  ),
                ),
              );
            },
            onEdit: () => onEdit(w),
          );
        },
        childCount: words.length,
      ),
    );
  }
}
