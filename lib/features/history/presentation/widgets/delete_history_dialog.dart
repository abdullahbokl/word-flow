import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wordflow/features/history/presentation/blocs/history/history_bloc.dart';

class DeleteHistoryDialog extends StatelessWidget {
  const DeleteHistoryDialog({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<HistoryBloc>().add(DeleteHistoryItemEvent(id));
            Navigator.pop(context);
          },
          child: const Text('Only History'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<HistoryBloc>().add(DeleteHistoryItemEvent(id, deleteUniqueWords: true));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          child: const Text('Delete Everything'),
        ),
      ],
    );
  }
}
