import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WordCardShimmer extends StatelessWidget {
  const WordCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Word text placeholder
                Container(height: 16, width: 120, decoration: BoxDecoration(
                  color: colorScheme.surface, borderRadius: BorderRadius.circular(4),
                )),
                const Spacer(),
                // Count badge placeholder
                Container(height: 24, width: 40, decoration: BoxDecoration(
                  color: colorScheme.surface, borderRadius: BorderRadius.circular(12),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: WordCardShimmer(),
      ),
    );
  }
}