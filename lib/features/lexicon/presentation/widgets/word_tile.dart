import 'package:flutter/material.dart';

import '../../../../core/domain/entities/word_entity.dart';

const _knownColor = Color(0xFF2E7D32);
const _seenTextStyle = TextStyle(fontSize: 12);

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
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: ValueKey(word.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withAlpha(50),
              width: 0.5,
            ),
          ),
        ),
        child: ListTile(
          onTap: onEdit,
          title: Text(
            word.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seen ${word.frequency}x',
                style: _seenTextStyle.copyWith(
                    color: colorScheme.onSurfaceVariant),
              ),
              if (word.meaning != null && word.meaning!.isNotEmpty)
                Text(
                  word.meaning!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: Icon(
                  word.isKnown ? Icons.check_circle : Icons.circle_outlined,
                  color: word.isKnown ? _knownColor : colorScheme.outline,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
