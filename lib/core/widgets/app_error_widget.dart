import 'package:flutter/material.dart';

import 'package:wordflow/core/constants/app_strings.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.error,
    this.onRetry,
    super.key,
  });

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFC62828)),
            const SizedBox(height: 16),
            Text(
              error,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
