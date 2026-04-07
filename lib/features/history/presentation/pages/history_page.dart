import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_navigator.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/sliver_status_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/history_card.dart';
import '../../domain/entities/history_item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            return CustomScrollView(
              key: const PageStorageKey<String>('history_scroll_view'),
              slivers: [
                const SliverToBoxAdapter(
                  child: PageHeader(title: 'Analysis History'),
                ),
                SliverStatusView<List<HistoryItem>>(
                  status: state.status,
                  onInitial: () => const SliverFillRemaining(
                    child: AppLoader(message: 'Loading history...'),
                  ),
                  onSuccess: (items) => _HistorySliverList(
                    items: items,
                    onDelete: (id) => _showDeleteDialog(context, id),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, int id) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Analysis'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How would you like to delete this analysis?'),
            SizedBox(height: 16),
            Text(
              '• Only history: Keeps all words in your lexicon.\n'
              '• History & unique words: Removes words that are only found in this text.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryBloc>().add(DeleteHistoryItemEvent(id));
              Navigator.pop(ctx);
            },
            child: const Text('Only History'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<HistoryBloc>()
                  .add(DeleteHistoryItemEvent(id, deleteUniqueWords: true));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}

class _HistorySliverList extends StatelessWidget {
  const _HistorySliverList({
    required this.items,
    required this.onDelete,
  });

  final List<HistoryItem> items;
  final Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyState(
          icon: Icons.history,
          title: 'No analysis history',
          subtitle: 'Analyzed texts will appear here.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverPrototypeExtentList(
        prototypeItem: HistoryCard(
          item: HistoryItem(
            id: -1,
            title: 'Prototype',
            totalWords: 0,
            uniqueWords: 0,
            createdAt: DateTime.now(),
            contentSnippet: 'Snippet',
          ),
          onTap: () {},
          onDelete: () {},
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            final item = items[i];
            return HistoryCard(
              item: item,
              onTap: () => AppNavigator.toHistoryDetail(item.id),
              onDelete: () => onDelete(item.id),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
