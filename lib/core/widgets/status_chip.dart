import 'package:flutter/material.dart';

enum StatusChipVariant { neutral, success, warning, info }

class StatusChip extends StatelessWidget {

  const StatusChip({
    super.key,
    required this.label,
    required this.icon,
    this.variant = StatusChipVariant.neutral,
  });
  final String label;
  final IconData icon;
  final StatusChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (variant) {
      StatusChipVariant.success => (
        colors.primary.withValues(alpha: 0.12),
        colors.primary,
      ),
      StatusChipVariant.warning => (
        colors.secondary.withValues(alpha: 0.14),
        colors.secondary,
      ),
      StatusChipVariant.info => (
        colors.tertiary.withValues(alpha: 0.14),
        colors.tertiary,
      ),
      StatusChipVariant.neutral => (
        colors.surfaceContainerHighest.withValues(alpha: 0.7),
        colors.onSurfaceVariant,
      ),
    };

    return Chip(
      avatar: Icon(icon, size: 16, color: foreground),
      label: Text(label),
      backgroundColor: background,
      side: BorderSide(color: foreground.withValues(alpha: 0.2)),
      labelStyle: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: foreground),
      padding: EdgeInsets.zero,
    );
  }
}
