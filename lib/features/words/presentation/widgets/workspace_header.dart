import 'package:flutter/material.dart';
import '../../../../core/utils/script_analysis.dart';
import '../../../../core/widgets/sync_status_badge.dart';
import '../../../../features/auth/presentation/widgets/auth_status_bar.dart';
import '../../../../app/router/routes.dart';
import 'metric_tile.dart';

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
            Row(
              children: [
                const Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [SyncStatusBadge(), AuthStatusBar()],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => const LibraryRoute().push(context),
                  icon: const Icon(Icons.library_books_rounded, size: 20),
                  tooltip: 'My Words Library',
                ),
              ],
            ),
            const SizedBox(height: 10),
            _MetricsSection(summary: summary),
          ],
        ),
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  final ScriptSummary summary;
  const _MetricsSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth >= 420 ? (constraints.maxWidth - 16) / 3 : (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MetricTile(width: tileWidth, label: 'Total words', value: summary.totalWords.toString(), icon: Icons.short_text_rounded),
            MetricTile(width: tileWidth, label: 'Unique words', value: summary.uniqueWords.toString(), icon: Icons.fingerprint_rounded),
            MetricTile(width: tileWidth, label: 'New words', value: summary.newWords.toString(), icon: Icons.auto_awesome_rounded),
          ],
        );
      },
    );
  }
}
