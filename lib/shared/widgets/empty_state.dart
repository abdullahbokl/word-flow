import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 64, 
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              title, 
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle, 
              style: Theme.of(context).textTheme.bodySmall, 
              textAlign: TextAlign.center
            ),
            if (action != null) ...[
              const SizedBox(height: 24), 
              action!
            ],
          ],
        ),
      ),
    );
  }
}