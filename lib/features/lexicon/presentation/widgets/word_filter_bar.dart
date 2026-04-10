import 'package:flutter/material.dart';
import 'package:lexitrack/core/theme/app_colors.dart';
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
        ...WordFilter.values.map((f) {
          final isActive = f == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              visualDensity: VisualDensity.compact,
              label: Text(f.name[0].toUpperCase() + f.name.substring(1)),
              selected: isActive,
              onSelected: (_) => onChanged(f),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: isActive ? AppColors.primary : null,
                fontWeight: isActive ? FontWeight.w600 : null,
                fontSize: 13,
              ),
            ),
          );
        }),
        const Spacer(),
        _SortMenu(
          current: activeSort,
          onChanged: onSortChanged,
        ),
      ],
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
