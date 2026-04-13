import 'package:flutter/material.dart';

import 'package:wordflow/core/constants/app_strings.dart';

class WordListSectionFilterToggle extends StatelessWidget {
  const WordListSectionFilterToggle({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(
            value: 0, label: Text(AppStrings.all), icon: Icon(Icons.list)),
        ButtonSegment(
          value: 1,
          label: Text(AppStrings.known),
          icon: Icon(Icons.check_circle_outline),
        ),
        ButtonSegment(
          value: 2,
          label: Text(AppStrings.unknownLabel),
          icon: Icon(Icons.help_outline),
        ),
      ],
      selected: {selectedIndex},
      onSelectionChanged: (set) => onSelected(set.first),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
