import 'package:flutter/material.dart';
import 'package:lexitrack/core/common/models/word_with_local_freq.dart';
import 'package:lexitrack/core/constants/app_strings.dart';
import 'package:lexitrack/core/widgets/app_text.dart';
import 'package:lexitrack/core/widgets/word_list_section.dart';
import 'package:lexitrack/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:lexitrack/features/text_analyzer/presentation/widgets/comprehension_card.dart';
import 'package:lexitrack/features/text_analyzer/presentation/widgets/excluded_words_shortcut.dart';
import 'package:lexitrack/features/text_analyzer/presentation/widgets/stat_grid.dart';

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
        _buildHeader(onReset),
        _buildTitle(result.title, theme),
        _buildComprehension(result.comprehension),
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverToBoxAdapter(child: ExcludedWordsShortcut()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(child: StatGrid(result: result)),
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

  Widget _buildHeader(VoidCallback onReset) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              const Expanded(child: AppText.headline(AppStrings.analysisResults)),
              IconButton(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Analyze Another Text',
              ),
            ],
          ),
        ),
      );

  Widget _buildTitle(String title, ThemeData theme) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        sliver: SliverToBoxAdapter(
          child: AppText.body(title, color: theme.colorScheme.onSurfaceVariant),
        ),
      );

  Widget _buildComprehension(double comprehension) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        sliver: SliverToBoxAdapter(
          child: ComprehensionCard(percentage: comprehension),
        ),
      );
}
