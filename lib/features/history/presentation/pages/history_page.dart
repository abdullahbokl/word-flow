import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wordflow/core/widgets/app_loader.dart';
import 'package:wordflow/core/widgets/page_header.dart';
import 'package:wordflow/core/widgets/sliver_status_view.dart';
import 'package:wordflow/features/history/domain/entities/history_item.dart';
import 'package:wordflow/features/history/presentation/blocs/history/history_bloc.dart';
import 'package:wordflow/features/history/presentation/widgets/delete_history_dialog.dart';
import 'package:wordflow/features/history/presentation/widgets/history_sliver_list.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.offset >=
            (_scrollController.position.maxScrollExtent * 0.9)) {
      context.read<HistoryBloc>().add(const LoadMoreHistory());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) => CustomScrollView(
            controller: _scrollController,
            key: const PageStorageKey<String>('history_scroll_view'),
            slivers: [
              const SliverToBoxAdapter(
                  child: PageHeader(title: 'Analysis History')),
              SliverStatusView<List<HistoryItem>>(
                status: state.status,
                onInitial: () => const SliverFillRemaining(
                    child: AppLoader(message: 'Loading history...')),
                onSuccess: (items) => HistorySliverList(
                  items: items,
                  hasReachedMax: state.hasReachedMax,
                  onDelete: (id) => showDialog(
                      context: context,
                      builder: (_) => DeleteHistoryDialog(id: id)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
