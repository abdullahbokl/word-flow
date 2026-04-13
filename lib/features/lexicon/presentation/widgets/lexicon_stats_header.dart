import 'package:flutter/material.dart';
import 'package:wordflow/core/constants/app_dimensions.dart';
import 'package:wordflow/core/theme/app_colors.dart';
import 'package:wordflow/core/widgets/stat_card.dart';
import 'package:wordflow/features/lexicon/domain/entities/lexicon_stats.dart';

class LexiconStatsHeader extends StatelessWidget {
  const LexiconStatsHeader({
    required this.stats,
    super.key,
  });

  final LexiconStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.space8,
        AppDimensions.pagePadding,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Total',
              value: '${stats.total}',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              label: 'Known',
              value: '${stats.known}',
              color: AppColors.statusKnown,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              label: 'Unknown',
              value: '${stats.unknown}',
              color: AppColors.statusUnknown,
            ),
          ),
        ],
      ),
    );
  }
}
