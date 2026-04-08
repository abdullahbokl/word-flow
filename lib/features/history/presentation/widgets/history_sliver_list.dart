import 'package:flutter/material.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../domain/entities/history_item.dart';
import '../widgets/history_card.dart';

class HistorySliverList extends StatelessWidget {
  const HistorySliverList({
    required this.items,
    required this.onDelete,
    super.key,
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
