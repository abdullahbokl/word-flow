import 'package:flutter/material.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/library_state.dart';

class LibraryFilterRow extends StatelessWidget {
  const LibraryFilterRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final WordsFilter selectedFilter;
  final ValueChanged<WordsFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _StyledFilterChip(
            label: 'All',
            isSelected: selectedFilter == WordsFilter.all,
            onSelected: () => onFilterChanged(WordsFilter.all),
          ),
          const SizedBox(width: 10),
          _StyledFilterChip(
            label: 'Known',
            isSelected: selectedFilter == WordsFilter.known,
            onSelected: () => onFilterChanged(WordsFilter.known),
          ),
          const SizedBox(width: 10),
          _StyledFilterChip(
            label: 'Unknown',
            isSelected: selectedFilter == WordsFilter.unknown,
            onSelected: () => onFilterChanged(WordsFilter.unknown),
          ),
        ],
      ),
    );
  }
}

class _StyledFilterChip extends StatelessWidget {
  const _StyledFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
