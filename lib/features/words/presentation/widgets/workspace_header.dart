import 'package:flutter/material.dart';

import '../../../../core/utils/script_analysis.dart';
import '../../../../core/widgets/sync_status_badge.dart';
import '../../../../features/auth/presentation/widgets/auth_status_bar.dart';

class WorkspaceHeader extends StatelessWidget {
  final ScriptSummary summary;

  const WorkspaceHeader({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [SyncStatusBadge(), AuthStatusBar()],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = constraints.maxWidth >= 420
                    ? (constraints.maxWidth - 16) / 3
                    : (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetricTile(
                      width: tileWidth,
                      label: 'Total words',
                      value: summary.totalWords.toString(),
                      icon: Icons.short_text_rounded,
                    ),
                    _MetricTile(
                      width: tileWidth,
                      label: 'Unique words',
                      value: summary.uniqueWords.toString(),
                      icon: Icons.fingerprint_rounded,
                    ),
                    _MetricTile(
                      width: tileWidth,
                      label: 'New words',
                      value: summary.newWords.toString(),
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value, style: textTheme.titleMedium),
                    Text(label, style: textTheme.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
