import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lexitrack/core/constants/app_dimensions.dart';
import 'package:lexitrack/core/constants/app_strings.dart';
import 'package:lexitrack/core/domain/entities/word_entity.dart';
import 'package:lexitrack/core/widgets/app_loader.dart';
import 'package:lexitrack/core/widgets/app_text_field.dart';
import 'package:lexitrack/core/widgets/page_header.dart';
import 'package:lexitrack/core/widgets/sliver_status_view.dart';
import 'package:lexitrack/features/lexicon/domain/entities/lexicon_stats.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_filter.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_sort.dart';
import 'package:lexitrack/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:lexitrack/features/lexicon/presentation/widgets/add_word_dialog.dart';
import 'package:lexitrack/features/lexicon/presentation/widgets/edit_word_dialog.dart';
import 'package:lexitrack/features/lexicon/presentation/widgets/lexicon_stats_header.dart';
import 'package:lexitrack/features/lexicon/presentation/widgets/word_filter_bar.dart';
import 'package:lexitrack/features/lexicon/presentation/widgets/words_sliver_list.dart';

class LexiconPage extends StatefulWidget {
  const LexiconPage({super.key});

  @override
  State<LexiconPage> createState() => _LexiconPageState();
}

class _LexiconPageState extends State<LexiconPage>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  final _listScrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = context.read<LexiconBloc>().state.query;
    _listScrollController.addListener(_onListScroll);
  }

  void _onListScroll() {
    if (_listScrollController.hasClients &&
        _listScrollController.offset >=
            (_listScrollController.position.maxScrollExtent * 0.9)) {
      context.read<LexiconBloc>().add(const FetchMoreLexicon());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    if (q != context.read<LexiconBloc>().state.query) {
      context.read<LexiconBloc>().add(SearchLexicon(q));
    }
  }

  Future<void> _showAdd() async {
    final res = await showDialog<String>(
        context: context, builder: (_) => const AddWordDialog());
    if (!mounted) return;
    if (res != null && res.isNotEmpty) {
      context.read<LexiconBloc>().add(AddWordManuallyEvent(res));
    }
  }

  Future<void> _showEdit(WordEntity w) async {
    final res = await showDialog<Map<String, dynamic>>(
        context: context, builder: (_) => EditWordDialog(word: w));
    if (!mounted) return;
    if (res != null) {
      context.read<LexiconBloc>().add(UpdateWordEvent(
            w.id,
            text: res['text'] as String?,
            meaning: res['meaning'] as String?,
            definitions: res['definitions'] as List<String>?,
            examples: res['examples'] as List<String>?,
            translations: res['translations'] as List<String>?,
            synonyms: res['synonyms'] as List<String>?,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: _showAdd, child: const Icon(Icons.add)),
      body: SafeArea(
        child: CustomScrollView(
          controller: _listScrollController,
          slivers: [
            const SliverToBoxAdapter(
                child: PageHeader(title: AppStrings.myLexicon)),
            SliverAppBar(
              floating: true,
              elevation: 1,
              toolbarHeight: 0,
              expandedHeight: 235,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: RepaintBoundary(
                  child: Column(
                    children: [
                      BlocSelector<LexiconBloc, LexiconState, LexiconStats>(
                        selector: (state) => state.stats,
                        builder: (ctx, stats) =>
                            LexiconStatsHeader(stats: stats),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pagePadding),
                        child: AppTextField(
                          controller: _searchCtrl,
                          hint: AppStrings.searchWords,
                          prefixIcon: Icons.search,
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pagePadding),
                        child: Row(
                          children: [
                            Expanded(
                              child: BlocSelector<LexiconBloc, LexiconState,
                                  WordFilter>(
                                selector: (state) => state.filter,
                                builder: (ctx, filter) => WordFilterBar(
                                  active: filter,
                                  onChanged: (f) => ctx
                                      .read<LexiconBloc>()
                                      .add(FilterLexicon(f)),
                                  // activeSort: filterState.sort, // Removed from here
                                  // onSortChanged: (s) => ctx.read<LexiconBloc>().add(SortLexicon(s)),
                                ),
                              ),
                            ),
                            BlocSelector<LexiconBloc, LexiconState, WordSort>(
                              selector: (state) => state.sort,
                              builder: (ctx, sort) => _SortButton(
                                active: sort,
                                onChanged: (s) =>
                                    ctx.read<LexiconBloc>().add(SortLexicon(s)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
            BlocBuilder<LexiconBloc, LexiconState>(
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  prev.hasReachedMax != curr.hasReachedMax,
              builder: (ctx, state) {
                final s = state.status;
                return SliverStatusView<List<WordEntity>>(
                  status: s,
                  animate: false,
                  onInitial: () => const SliverFillRemaining(
                      child: AppLoader(message: AppStrings.loadingLexicon)),
                  onSuccess: (words) => WordsSliverList(
                    words: words,
                    hasReachedMax: state.hasReachedMax,
                    onEdit: _showEdit,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.active, required this.onChanged});
  final WordSort active;
  final ValueChanged<WordSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        icon: const Icon(Icons.sort_rounded, size: 20),
        tooltip: 'Sort by',
        visualDensity: VisualDensity.compact,
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
      ),
      menuChildren: WordSort.values.map((sort) {
        final isSelected = sort == active;
        return MenuItemButton(
          onPressed: () => onChanged(sort),
          leadingIcon: Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
          child: Text(
            sort.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}
