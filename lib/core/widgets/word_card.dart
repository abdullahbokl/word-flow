import 'package:flutter/material.dart';

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
              _StatusIndicator(isKnown: isKnown, color: statusColor),
              const SizedBox(width: 14),
              Expanded(
                child: _WordInfo(text: text, count: count, isKnown: isKnown),
              ),
              if (onToggle != null)
                _ToggleButton(
                  isKnown: isKnown,
                  isPending: isPending,
                  onToggle: onToggle!,
                  statusColor: statusColor,
                ),
              if (actions != null) ...actions!,
              if (isPending && onToggle == null) _InlineLoading(color: statusColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool isKnown;
  final Color color;
  const _StatusIndicator({required this.isKnown, required this.color});
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

class _WordInfo extends StatelessWidget {
  final String text;
  final int count;
  final bool isKnown;
  const _WordInfo({required this.text, required this.count, required this.isKnown});
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

class _ToggleButton extends StatelessWidget {
  final bool isKnown;
  final bool isPending;
  final VoidCallback onToggle;
  final Color statusColor;
  const _ToggleButton({required this.isKnown, required this.isPending, required this.onToggle, required this.statusColor});
  @override
  Widget build(BuildContext context) => IconButton(
        icon: isPending
            ? _InlineLoading(color: statusColor)
            : Icon(
                isKnown ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: isKnown ? Theme.of(context).colorScheme.primary : null,
              ),
        onPressed: isPending ? null : onToggle,
        tooltip: 'Toggle status',
      );
}

class _InlineLoading extends StatelessWidget {
  final Color color;
  const _InlineLoading({required this.color});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
}
