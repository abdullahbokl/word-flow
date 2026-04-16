import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/theme/app_colors.dart';
import 'package:wordflow/core/theme/design_tokens.dart';
import 'package:wordflow/core/widgets/stat_card.dart';
import 'package:wordflow/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:wordflow/features/review/presentation/blocs/review_bloc.dart';
import 'package:wordflow/features/review/presentation/pages/review_session_page.dart';

class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: AppTokens.space24),
        _buildStatsGrid(context),
      ],
    )
        .animate()
        .fadeIn(duration: AppTokens.durNormal)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<LexiconBloc, LexiconState>(
      builder: (context, state) {
        final stats = state.stats;
        final ratio = stats.total > 0 ? stats.known / stats.total : 0.0;

        return Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: ratio,
                    strokeWidth: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${(ratio * 100).toInt()}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppTokens.space24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    'You know ${stats.known} out of ${stats.total} words',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return BlocBuilder<LexiconBloc, LexiconState>(
      builder: (context, lexiconState) {
        return BlocBuilder<ReviewBloc, ReviewState>(
          builder: (context, reviewState) {
            final stats = lexiconState.stats;
            final dueCount = reviewState.maybeWhen(
              loaded: (dueWords) => dueWords.length,
              orElse: () => 0,
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > AppTokens.maxMobileWidth;
                final crossAxisCount = isWide ? 4 : 2;
                final childAspectRatio = isWide ? 1.35 : 1.5;

                return Column(
                  children: [
                    GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppTokens.space16,
                      crossAxisSpacing: AppTokens.space16,
                      childAspectRatio: childAspectRatio,
                      children: [
                        StatCard(
                          label: 'TOTAL WORDS',
                          value: stats.total.toString(),
                          color: AppColors.primary,
                        ),
                        StatCard(
                          label: 'KNOWN',
                          value: stats.known.toString(),
                          color: AppColors.statusKnown,
                        ),
                        StatCard(
                          label: 'UNKNOWN',
                          value: stats.unknown.toString(),
                          color: AppColors.statusUnknown,
                        ),
                        StatCard(
                          label: 'DUE FOR REVIEW',
                          value: dueCount.toString(),
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                    if (dueCount > 0) ...[
                      const SizedBox(height: AppTokens.space24),
                      _buildReviewCTA(context, dueCount),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReviewCTA(BuildContext context, int dueCount) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
        boxShadow: AppTokens.shadowMedium,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            unawaited(Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReviewSessionPage()),
            ));
          },
          borderRadius: BorderRadius.circular(AppTokens.radius16),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white),
                const SizedBox(width: AppTokens.space8),
                Text(
                  'Quick Review ($dueCount words)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack);
  }
}
