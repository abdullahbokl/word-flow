import 'package:flutter/material.dart';
import 'package:lexitrack/core/theme/app_colors.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_filter.dart';

class WordFilterBar extends StatelessWidget {
  const WordFilterBar({
    required this.active,
    required this.onChanged,
    super.key,
  });

  final WordFilter active;
  final ValueChanged<WordFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: WordFilter.values.map((f) {
          final isActive = f == active;
          final label = f == WordFilter.all
              ? 'All'
              : f == WordFilter.known
                  ? 'Known'
                  : 'Unknown';
          return RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: label,
                isSelected: isActive,
                onSelected: () => onChanged(f),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = AppColors.primary;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? primaryColor : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
