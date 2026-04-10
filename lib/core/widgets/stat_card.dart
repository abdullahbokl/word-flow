import 'package:flutter/material.dart';
import 'package:lexitrack/core/theme/design_tokens.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    this.color,
    super.key,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTokens.space16,
        horizontal: AppTokens.space24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.08),
        ),
        boxShadow: AppTokens.shadowLow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color ?? colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
