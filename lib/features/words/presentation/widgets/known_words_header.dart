import 'package:flutter/material.dart';

class KnownWordsHeader extends StatelessWidget {
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;

  const KnownWordsHeader({
    super.key,
    required this.count,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Text(
              'Known words ($count)',
              style: textTheme.titleSmall?.copyWith(color: scheme.secondary),
            ),
            const Spacer(),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: isExpanded ? 0.5 : 0,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: scheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
