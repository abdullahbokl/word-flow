import 'package:flutter/material.dart';

import 'package:lexitrack/core/common/models/word_with_local_freq.dart';

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

    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: AppText.headline(AppStrings.analysisResults),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: AppText.body(
              result.title,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          sliver: SliverToBoxAdapter(
            child: ComprehensionCard(percentage: result.comprehension),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _StatGrid(result: result),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
          sliver: WordListSection(
            words: result.words,
            onToggleStatus: onToggleStatus,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Analyze Another Text',
                onPressed: onReset,
                icon: Icons.refresh,
              ),
            ),
          ),
        ),
      ],
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
      ],
    );
  }
}
