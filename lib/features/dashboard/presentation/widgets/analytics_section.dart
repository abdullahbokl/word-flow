import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wordflow/core/theme/app_colors.dart';
import 'package:wordflow/core/theme/design_tokens.dart';

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Analytics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTokens.space16),
        _AnalyticsCard(
          title: 'Words Learned',
          subtitle: 'Last 7 days',
          child: _buildBarChart(context),
        ),
        const SizedBox(height: AppTokens.space24),
        _AnalyticsCard(
          title: 'Category Distribution',
          subtitle: 'Vocabulary breakdown',
          child: _buildPieChart(context),
        ),
        const SizedBox(height: AppTokens.space24),
        _AnalyticsCard(
          title: 'Review Accuracy',
          subtitle: 'Performance trend',
          child: _buildLineChart(context),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = _getHasData();

    if (hasData) {
      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(days[value.toInt()],
                        style: theme.textTheme.labelSmall);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (i + 1) * 2.0,
                  gradient: AppColors.primaryGradient,
                  width: 12,
                  borderRadius: BorderRadius.circular(AppTokens.radius4),
                ),
              ],
            );
          }),
        ),
      );
    }

    return _buildEmptyState(
      context,
      icon: Icons.bar_chart_rounded,
      message: 'No learning activity recorded yet',
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = _getHasData();

    if (hasData) {
      return PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: 40,
              title: 'Nouns',
              color: AppColors.primary,
              radius: 50,
              titleStyle:
                  theme.textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
            PieChartSectionData(
              value: 30,
              title: 'Verbs',
              color: AppColors.secondary,
              radius: 50,
              titleStyle:
                  theme.textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
            PieChartSectionData(
              value: 30,
              title: 'Other',
              color: AppColors.accent,
              radius: 50,
              titleStyle:
                  theme.textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return _buildEmptyState(
      context,
      icon: Icons.pie_chart_rounded,
      message: 'Categorize words to see distribution',
    );
  }

  Widget _buildLineChart(BuildContext context) {
    final hasData = _getHasData();

    if (hasData) {
      return LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(2.6, 2),
                FlSpot(4.9, 5),
                FlSpot(6.8, 3.1),
                FlSpot(8, 4),
                FlSpot(9.5, 3),
                FlSpot(11, 4),
              ],
              isCurved: true,
              gradient: AppColors.primaryGradient,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildEmptyState(
      context,
      icon: Icons.show_chart_rounded,
      message: 'Complete reviews to track accuracy',
    );
  }

  bool _getHasData() => false;

  Widget _buildEmptyState(BuildContext context,
      {required IconData icon, required String message}) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: AppTokens.space12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.space24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radius24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.05),
        ),
        boxShadow: AppTokens.shadowSubtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space24),
          SizedBox(
            height: 160,
            child: child,
          ),
        ],
      ),
    );
  }
}
