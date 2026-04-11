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
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: AppTokens.shadowLow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radius16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(
                color: (color ?? colorScheme.primary).withValues(alpha: 0.6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppTokens.space16,
                horizontal: AppTokens.space12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTokens.space8),
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: color ?? colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
