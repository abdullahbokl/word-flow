import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/lexicon_bloc.dart';
import '../bloc/lexicon_event.dart';
import '../bloc/lexicon_state.dart';
import '../widgets/word_filter_bar.dart';
import '../widgets/word_tile.dart';
import '../../../../core/widgets/theme_toggle.dart';

class LexiconPage extends StatefulWidget {
  const LexiconPage({super.key});

  @override
  State<LexiconPage> createState() => _LexiconPageState();
}

class _LexiconPageState extends State<LexiconPage> {
  final _searchCtrl = TextEditingController();
  final _addCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _addCtrl.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Word'),
        content: TextField(
          controller: _addCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter a word...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context
                  .read<LexiconBloc>()
                  .add(AddWordManuallyEvent(_addCtrl.text));
              _addCtrl.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lexicon'),
        actions: [
          const ThemeToggle(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<LexiconBloc, LexiconState>(
        builder: (context, state) => switch (state) {
          LexiconInitial() => const AppLoader(message: 'Loading lexicon...'),
          LexiconLoading() => const AppLoader(),
          LexiconFailure(:final message) => Center(child: Text(message)),
          LexiconLoaded() => _LoadedBody(
              state: state,
              searchCtrl: _searchCtrl,
            ),
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state, required this.searchCtrl});

  final LexiconLoaded state;
  final TextEditingController searchCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatsRow(state: state),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppTextField(
            controller: searchCtrl,
            hint: 'Search words...',
            prefixIcon: Icons.search,
            onChanged: (q) =>
                context.read<LexiconBloc>().add(SearchLexicon(q)),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: WordFilterBar(
            active: state.filter,
            onChanged: (f) =>
                context.read<LexiconBloc>().add(FilterLexicon(f)),
            activeSort: state.sort,
            onSortChanged: (s) =>
                context.read<LexiconBloc>().add(SortLexicon(s)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: state.words.isEmpty
              ? const AppEmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'No words yet',
                  subtitle: 'Analyze a text to populate your lexicon.',
                )
              : ListView.separated(
                  itemCount: state.words.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final w = state.words[i];
                    return WordTile(
                      word: w,
                      onToggle: () => ctx
                          .read<LexiconBloc>()
                          .add(ToggleWordStatusEvent(w.id)),
                      onDelete: () => ctx
                          .read<LexiconBloc>()
                          .add(DeleteWordEvent(w.id)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});

  final LexiconLoaded state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          StatCard(
            label: 'Total',
            value: '${state.stats.total}',
          ),
          const SizedBox(width: 10),
          StatCard(
            label: 'Known',
            value: '${state.stats.known}',
            color: AppColors.known,
          ),
          const SizedBox(width: 10),
          StatCard(
            label: 'Unknown',
            value: '${state.stats.unknown}',
            color: AppColors.unknown,
          ),
        ],
      ),
    );
  }
}
