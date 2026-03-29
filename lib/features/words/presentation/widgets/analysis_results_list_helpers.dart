import 'package:flutter/material.dart';

class RefreshingIndicator extends StatelessWidget {
  const RefreshingIndicator({
    super.key,
    required this.scheme,
    required this.textTheme,
  });
  final ColorScheme scheme;
  final TextTheme textTheme;
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                minHeight: 3,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 8),
              Text(
                'Refreshing results...',
                style: textTheme.labelSmall?.copyWith(color: scheme.primary),
              ),
            ],
          ),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, required this.color});
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
          ),
        ),
      );
}

class AnalysisDivider extends StatelessWidget {
  const AnalysisDivider({super.key});
  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(),
        ),
      );
}
