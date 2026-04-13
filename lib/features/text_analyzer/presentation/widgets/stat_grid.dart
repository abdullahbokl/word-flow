import 'package:flutter/material.dart';
import 'package:wordflow/core/widgets/stat_card.dart';
import 'package:wordflow/features/text_analyzer/domain/entities/analysis_result.dart';

class StatGrid extends StatelessWidget {
  const StatGrid({required this.result, super.key});

  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child:
                  StatCard(label: 'Total Words', value: '${result.totalWords}'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(label: 'Unique', value: '${result.uniqueWords}'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Unknown',
                value: '${result.unknownWords}',
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: 'Known Words',
                value: '${result.knownWords}',
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
