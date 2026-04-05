import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_text.dart';
import '../bloc/lexicon_bloc.dart';
import '../bloc/lexicon_event.dart';
import '../bloc/lexicon_state.dart';
import '../widgets/word_filter_bar.dart';
import '../widgets/word_tile.dart';
import '../widgets/lexicon_stats_header.dart';
import '../../domain/entities/word_entity.dart';
import '../../../../core/widgets/theme_toggle.dart';

class LexiconPage extends StatefulWidget {
  const LexiconPage({super.key});

  @override
  State<LexiconPage> createState() => _LexiconPageState();
}

class _LexiconPageState extends State<LexiconPage> {
  final _addCtrl = TextEditingController();

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  void _onAddWord() {
    _addCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText.title('Add Word'),
        content: AppTextField(
          controller: _addCtrl,
          autofocus: true,
          hint: 'Enter a word...',
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _onAddSubmitted(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText.body('Cancel'),
          ),
          ElevatedButton(
            onPressed: _onAddSubmitted,
            child: const AppText.body('Add'),
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
        title: const AppText.title('Edit Word'),
        content: AppTextField(
          controller: _addCtrl,
          autofocus: true,
          hint: 'Enter a word...',
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _onEditSubmitted(word),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText.body('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _onEditSubmitted(word),
            child: const AppText.body('Save'),
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
    final searchCtrl = TextEditingController(
      text: context.read<LexiconBloc>().state.query,
    );

    return Scaffold(
      appBar: AppBar(
        title: const AppText.headline('My Lexicon'),
        actions: const [ThemeToggle(), SizedBox(width: 8)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddWord,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<LexiconBloc, LexiconState>(
        builder: (context, state) => state.status.when(
          initial: () => const AppLoader(message: 'Loading lexicon...'),
          loading: () => const AppLoader(),
          failure: (error) => Center(child: AppText(error)),
          success: (words) => _LoadedBody(
            state: state,
            words: words,
            searchCtrl: searchCtrl,
            onEdit: _onEditWord,
          ),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.state,
    required this.words,
    required this.searchCtrl,
    required this.onEdit,
  });

  final LexiconState state;
  final List<WordEntity> words;
  final TextEditingController searchCtrl;
  final Function(WordEntity) onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LexiconStatsHeader(stats: state.stats),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppTextField(
            controller: searchCtrl,
            hint: 'Search words...',
            prefixIcon: Icons.search,
            onChanged: (q) => context.read<LexiconBloc>().add(SearchLexicon(q)),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: WordFilterBar(
            active: state.filter,
            onChanged: (f) => context.read<LexiconBloc>().add(FilterLexicon(f)),
            activeSort: state.sort,
            onSortChanged: (s) =>
                context.read<LexiconBloc>().add(SortLexicon(s)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: words.isEmpty
              ? const AppEmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'No words yet',
                  subtitle: 'Analyze a text to populate your lexicon.',
                )
              : ListView.separated(
                  itemCount: words.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final w = words[i];
                    return WordTile(
                      word: w,
                      onToggle: () => ctx
                          .read<LexiconBloc>()
                          .add(ToggleWordStatusEvent(w.id)),
                      onDelete: () => ctx
                          .read<LexiconBloc>()
                          .add(DeleteWordEvent(w.id)),
                      onEdit: () => onEdit(w),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
