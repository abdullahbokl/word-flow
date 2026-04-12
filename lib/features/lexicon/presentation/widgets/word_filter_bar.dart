import 'package:flutter/material.dart';
import 'package:lexitrack/core/theme/app_colors.dart';
import 'package:lexitrack/core/constants/app_dimensions.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_filter.dart';
import 'package:lexitrack/features/lexicon/domain/entities/word_sort.dart';

class WordFilterBar extends StatelessWidget {
  const WordFilterBar({
    required this.active,
    required this.onChanged,
    required this.activeSort,
    required this.onSortChanged,
    super.key,
  });

  final WordFilter active;
  final ValueChanged<WordFilter> onChanged;
  final WordSort activeSort;
  final ValueChanged<WordSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
            ),
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
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.pagePadding),
          child: _SortMenu(
            current: activeSort,
            onChanged: onSortChanged,
          ),
        ),
      ],
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

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.current, required this.onChanged});
  final WordSort current;
  final ValueChanged<WordSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        icon: const Icon(Icons.sort_rounded, size: 20),
        tooltip: 'Sort by',
        visualDensity: VisualDensity.compact,
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
      ),
      menuChildren: WordSort.values.map((sort) {
        final isSelected = sort == current;
        return MenuItemButton(
          onPressed: () => onChanged(sort),
          leadingIcon: Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
          child: Text(
            sort.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}
