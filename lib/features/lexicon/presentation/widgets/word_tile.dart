import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/word_entity.dart';

class WordTile extends StatelessWidget {
  const WordTile({
    required this.word,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final WordEntity word;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(word.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(
          word.text,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
        ),
        subtitle: Text('Seen ${word.frequency}×'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(isKnown: word.isKnown),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                word.isKnown ? Icons.check_circle : Icons.circle_outlined,
                color: word.isKnown ? const Color(0xFF2E7D32) : null,
              ),
              onPressed: onToggle,
              tooltip: word.isKnown ? 'Mark unknown' : 'Mark known',
            ),
          ],
        ),
      ),
    );
  }
}
