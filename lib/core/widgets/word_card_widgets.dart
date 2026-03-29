import 'package:flutter/material.dart';
import 'package:word_flow/core/widgets/app_loader.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.isKnown, required this.color});
  final bool isKnown;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isKnown ? Icons.verified_rounded : Icons.auto_awesome_rounded,
          color: color,
          size: 20,
        ),
      );
}

class WordInfo extends StatelessWidget {
  const WordInfo({super.key, required this.text, required this.count, required this.isKnown});
  final String text;
  final int count;
  final bool isKnown;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(
          'Count: $count • ${isKnown ? "Known" : "Unknown"}',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

class ToggleButton extends StatelessWidget {
  const ToggleButton({super.key, required this.isKnown, required this.isPending, required this.onToggle, required this.statusColor});
  final bool isKnown;
  final bool isPending;
  final VoidCallback onToggle;
  final Color statusColor;
  @override
  Widget build(BuildContext context) => IconButton(
        icon: isPending
            ? AppLoader(size: 16, color: statusColor)
            : Icon(
                isKnown ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: isKnown ? Theme.of(context).colorScheme.primary : null,
              ),
        onPressed: isPending ? null : onToggle,
        tooltip: 'Toggle status',
      );
}
