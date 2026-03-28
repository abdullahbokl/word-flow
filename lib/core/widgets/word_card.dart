import 'package:flutter/material.dart';
import 'app_loader.dart';
import 'word_card_widgets.dart';

class WordCard extends StatelessWidget {
  final String text;
  final int count;
  final bool isKnown;
  final bool isPending;
  final VoidCallback? onToggle;
  final List<Widget>? actions;

  const WordCard({
    super.key,
    required this.text,
    required this.count,
    this.isKnown = false,
    this.isPending = false,
    this.onToggle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = isKnown ? scheme.primary : scheme.secondary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isPending ? 0.35 : 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              StatusIndicator(isKnown: isKnown, color: statusColor),
              const SizedBox(width: 14),
              Expanded(
                child: WordInfo(text: text, count: count, isKnown: isKnown),
              ),
              if (onToggle != null)
                ToggleButton(
                  isKnown: isKnown,
                  isPending: isPending,
                  onToggle: onToggle!,
                  statusColor: statusColor,
                ),
              if (actions != null) ...actions!,
              if (isPending && onToggle == null) AppLoader(size: 16, color: statusColor),
            ],
          ),
        ),
      ),
    );
  }
}

