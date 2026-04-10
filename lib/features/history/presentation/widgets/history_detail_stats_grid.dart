import 'package:flutter/material.dart';
import 'package:lexitrack/core/theme/app_colors.dart';
import 'package:lexitrack/core/widgets/stat_card.dart';
import 'package:lexitrack/features/history/domain/entities/history_detail.dart';

class HistoryDetailStatsGrid extends StatelessWidget {
  const HistoryDetailStatsGrid({required this.detail, super.key});
  final HistoryDetail detail;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        StatCard(
          label: 'Total Words',
          value: '${detail.item.totalWords}',
          color: AppColors.primary,
        ),
        StatCard(
          label: 'Unique Words',
          value: '${detail.item.uniqueWords}',
          color: AppColors.secondary,
        ),
        StatCard(
          label: 'Known Words',
          value: '${detail.item.knownWords}',
          color: AppColors.success,
        ),
        StatCard(
          label: 'Unknown',
          value: '${detail.item.unknownWords}',
          color: AppColors.error,
        ),
      ],
    );
  }
}
