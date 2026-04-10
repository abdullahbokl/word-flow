import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/domain/entities/word_entity.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/sliver_status_view.dart';
import '../blocs/lexicon/lexicon_bloc.dart';
import '../widgets/add_word_dialog.dart';
import '../widgets/edit_word_dialog.dart';
import '../widgets/lexicon_toolbar.dart';
import '../widgets/words_sliver_list.dart';

class LexiconPage extends StatefulWidget {
  const LexiconPage({super.key});

  @override
  State<LexiconPage> createState() => _LexiconPageState();
}

class _LexiconPageState extends State<LexiconPage>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  final _listScrollController = ScrollController();
  Timer? _searchDebounce;

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
      context.read<LexiconBloc>().add(const LoadMoreLexicon());
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (q != context.read<LexiconBloc>().state.query) {
        context.read<LexiconBloc>().add(SearchLexicon(q));
      }
    });
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
        child: BlocBuilder<LexiconBloc, LexiconState>(
          builder: (ctx, state) => CustomScrollView(
            controller: _listScrollController,
            slivers: [
              const SliverToBoxAdapter(
                  child: PageHeader(title: AppStrings.myLexicon)),
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 1,
                toolbarHeight: 0,
                expandedHeight: 215,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: LexiconToolbar(
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
                    child: AppLoader(message: AppStrings.loadingLexicon)),
                onSuccess: (words) => WordsSliverList(
                    words: words,
                    hasReachedMax: state.hasReachedMax,
                    onEdit: _showEdit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
