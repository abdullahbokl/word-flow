import 'package:lexitrack/core/common/models/word_with_local_freq.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/word_list_section.dart';
import '../../domain/entities/analysis_result.dart';
import 'comprehension_card.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText.headline(AppStrings.analysisResults),
          const SizedBox(height: 8),
          AppText.body(result.title, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 24),
          ComprehensionCard(percentage: result.comprehension),
          const SizedBox(height: 16),
          _StatGrid(result: result),
          const SizedBox(height: 32),
          WordListSection(words: result.words, onToggleStatus: onToggleStatus),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AppButton(label: 'Analyze Another Text', onPressed: onReset, icon: Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.result});
  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatCard(label: 'Total Words', value: '${result.totalWords}')),
            const SizedBox(width: 8),
            Expanded(child: StatCard(label: 'Unique', value: '${result.uniqueWords}')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: StatCard(label: 'Unknown', value: '${result.unknownWords}', color: theme.colorScheme.error)),
            const SizedBox(width: 8),
            Expanded(child: StatCard(label: 'Known Words', value: '${result.knownWords}', color: theme.colorScheme.primary)),
          ],
        ),
      ],
    );
  }
}
