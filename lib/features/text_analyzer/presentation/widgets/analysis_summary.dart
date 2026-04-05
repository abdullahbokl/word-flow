import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/word_list_section.dart';
import '../../../../core/common/models/word_with_local_freq.dart';
import '../../domain/entities/analysis_result.dart';

class AnalysisSummary extends StatelessWidget {
  const AnalysisSummary({
    required this.result,
    required this.onReset,
    this.onToggleStatus,
    super.key,
  });

  final AnalysisResult result;
  final VoidCallback onReset;
  final ValueChanged<WordWithLocalFreq>? onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comp = result.comprehension;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText.headline('Analysis Results'),
          const SizedBox(height: 8),
          AppText.body(
            result.title,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          _ComprehensionCard(percentage: comp),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Words',
                  value: '${result.totalWords}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Unique',
                  value: '${result.uniqueWords}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Unknown',
                  value: '${result.unknownWords}',
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Known Words',
                  value: '${result.knownWords}',
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          WordListSection(
            words: result.words,
            onToggleStatus: onToggleStatus,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Analyze Another Text',
              onPressed: onReset,
              icon: Icons.refresh,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComprehensionCard extends StatelessWidget {
  const _ComprehensionCard({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = percentage > 90
        ? Colors.green
        : percentage > 70
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.title(
                'Comprehension Score',
                color: color,
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: color,
                  fontSize: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
