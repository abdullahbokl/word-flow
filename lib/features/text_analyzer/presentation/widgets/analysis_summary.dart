import 'package:flutter/material.dart';

import 'package:lexitrack/core/common/models/word_with_local_freq.dart';

import 'package:lexitrack/core/constants/app_strings.dart';
import 'package:lexitrack/core/widgets/app_text.dart';
import 'package:lexitrack/core/widgets/stat_card.dart';
import 'package:lexitrack/core/widgets/word_list_section.dart';
import 'package:lexitrack/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:lexitrack/features/text_analyzer/presentation/widgets/comprehension_card.dart';

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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Expanded(
                  child: AppText.headline(AppStrings.analysisResults),
                ),
                IconButton(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Analyze Another Text',
                ),
              ],
            ),
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
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
          sliver: WordListSection(
            words: result.words,
            onToggleStatus: onToggleStatus,
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
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: 'Unique',
                value: '${result.uniqueWords}',
              ),
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
