import 'package:flutter/material.dart';
import '../cubit/library_state.dart';

class LibraryFilterRow extends StatelessWidget {
  final WordsFilter selectedFilter;
  final ValueChanged<WordsFilter> onFilterChanged;

  const LibraryFilterRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StyledFilterChip(
            label: 'All',
            isSelected: selectedFilter == WordsFilter.all,
            onSelected: () => onFilterChanged(WordsFilter.all),
          ),
          const SizedBox(width: 8),
          _StyledFilterChip(
            label: 'Known',
            isSelected: selectedFilter == WordsFilter.known,
            onSelected: () => onFilterChanged(WordsFilter.known),
          ),
          const SizedBox(width: 8),
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
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _StyledFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }
}
