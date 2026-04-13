import 'package:flutter/material.dart';
import 'package:wordflow/core/navigation/app_navigator.dart';
import 'package:wordflow/core/widgets/app_empty_state.dart';
import 'package:wordflow/core/widgets/app_loader.dart';
import 'package:wordflow/features/history/domain/entities/history_item.dart';
import 'package:wordflow/features/history/presentation/widgets/history_card.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HistorySliverList extends StatelessWidget {
  const HistorySliverList({
    required this.items,
    required this.onDelete,
    this.hasReachedMax = false,
    super.key,
  });

  final List<HistoryItem> items;
  final bool hasReachedMax;
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

    return MultiSliver(
      children: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final item = items[i];
                return RepaintBoundary(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HistoryCard(
                      item: item,
                      onTap: () => AppNavigator.toHistoryDetail(item.id),
                      onDelete: () => onDelete(item.id),
                    ),
                  ),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
        if (!hasReachedMax)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: AppLoader(),
            ),
          ),
      ],
    );
  }
}
