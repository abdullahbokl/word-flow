import 'package:flutter/material.dart';
import 'package:lexitrack/core/theme/app_colors.dart';
import 'package:lexitrack/core/widgets/stat_card.dart';
import 'package:lexitrack/features/lexicon/domain/entities/lexicon_stats.dart';

class LexiconStatsHeader extends StatelessWidget {
  const LexiconStatsHeader({
    required this.stats,
    super.key,
  });

  final LexiconStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
