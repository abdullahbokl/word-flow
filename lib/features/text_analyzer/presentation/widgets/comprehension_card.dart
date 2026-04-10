import 'package:flutter/material.dart';

import 'package:lexitrack/core/theme/app_colors.dart';
import 'package:lexitrack/core/widgets/app_text.dart';

class ComprehensionCard extends StatelessWidget {
  const ComprehensionCard({required this.percentage, super.key});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = percentage > 90
        ? AppColors.success
        : percentage > 70
            ? AppColors.warning
            : AppColors.error;

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
