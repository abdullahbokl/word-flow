import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  final String text;
  final int count;
  final VoidCallback? onToggle;
  final bool isKnown;

  const WordCard({
    super.key,
    required this.text,
    required this.count,
    required this.onToggle,
    this.isKnown = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = isKnown ? colorScheme.primary : colorScheme.secondary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isKnown ? Icons.check_rounded : Icons.auto_awesome_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      '$count ${count == 1 ? 'occurrence' : 'occurrences'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: onToggle,
                tooltip: isKnown ? 'Mark as unknown' : 'Mark as known',
                icon: Icon(
                  isKnown ? Icons.remove_done_rounded : Icons.check_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
