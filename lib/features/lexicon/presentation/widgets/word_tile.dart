import 'package:flutter/material.dart';

import '../../domain/entities/word_entity.dart';

class WordTile extends StatelessWidget {
  const WordTile({
    required this.word,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  final WordEntity word;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

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
        onTap: onEdit,
        title: Text(
          word.text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seen ${word.frequency}×', style: const TextStyle(fontSize: 12)),
            if (word.meaning != null && word.meaning!.isNotEmpty)
              Text(
                word.meaning!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit details',
            ),
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
