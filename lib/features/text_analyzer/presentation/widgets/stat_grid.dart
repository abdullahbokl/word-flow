import 'package:flutter/material.dart';
import 'package:wordflow/core/widgets/stat_card.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';

class StatGrid extends StatelessWidget {
  const StatGrid({required this.result, super.key});

  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600; // Consistent with AppTokens.maxMobileWidth
        final crossAxisCount = isWide ? 4 : 2;
        final childAspectRatio = isWide ? 1.35 : 1.5;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            StatCard(label: 'Total Words', value: '${result.totalWords}'),
            StatCard(label: 'Unique', value: '${result.uniqueWords}'),
            StatCard(
              label: 'Unknown',
              value: '${result.unknownWords}',
              color: theme.colorScheme.error,
            ),
            StatCard(
              label: 'Known Words',
              value: '${result.knownWords}',
              color: theme.colorScheme.primary,
            ),
          ],
        );
      },
    );
  }
}
