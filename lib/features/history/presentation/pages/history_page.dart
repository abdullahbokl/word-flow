import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_navigator.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/history_card.dart';
import '../../../../core/widgets/theme_toggle.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: const [ThemeToggle(), SizedBox(width: 8)],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) => state.status.when(
          initial: () => const AppLoader(message: 'Loading history...'),
          loading: () => const AppLoader(),
          failure: (error) => Center(child: Text(error)),
          success: (items) => items.isEmpty
              ? const AppEmptyState(
                  icon: Icons.history,
                  title: 'No analysis history',
                  subtitle: 'Analyzed texts will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return HistoryCard(
                      item: item,
                      onTap: () => AppNavigator.toHistoryDetail(item.id),
                      onDelete: () => _showDeleteDialog(ctx, item.id),
                    );
                  },
                ),
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
