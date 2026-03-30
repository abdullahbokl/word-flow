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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          child: Icon(
            isKnown ? Icons.verified_rounded : Icons.auto_awesome_rounded,
            key: ValueKey('status_${isKnown ? 'known' : 'unknown'}'),
            color: color,
            size: 20,
          ),
        ),
      );
}

class WordInfo extends StatelessWidget {
  const WordInfo({
    super.key,
    required this.text,
    required this.count,
    required this.isKnown,
    this.variants = const [],
  });
  final String text;
  final int count;
  final bool isKnown;
  final List<String> variants;
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
        if (variants.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Variants: ${variants.join(", ")}',
            style: textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
  Widget build(BuildContext context) => SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
            child: isPending
                ? AppLoader(key: const ValueKey('loader'), size: 16, color: statusColor)
                : Icon(
                    isKnown ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    key: ValueKey('checkbox_${isKnown ? 'checked' : 'unchecked'}'),
                    color: isKnown ? Theme.of(context).colorScheme.primary : null,
                  ),
          ),
          onPressed: isPending ? null : onToggle,
          tooltip: 'Toggle status',
        ),
      );
}
