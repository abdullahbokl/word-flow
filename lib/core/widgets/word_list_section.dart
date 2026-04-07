import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../../../../core/common/models/word_with_local_freq.dart';
import '../theme/app_colors.dart';

class WordListSection extends StatefulWidget {
  const WordListSection({
    super.key,
    required this.words,
    this.title = AppStrings.wordBreakdown,
    this.onToggleStatus,
  });

  final List<WordWithLocalFreq> words;
  final String title;
  final ValueChanged<WordWithLocalFreq>? onToggleStatus;

  @override
  State<WordListSection> createState() => _WordListSectionState();
}

class _WordListSectionState extends State<WordListSection> {
  int _filterIndex = 0; // 0: All, 1: Known, 2: Unknown

  List<WordWithLocalFreq> get _filteredWords {
    if (_filterIndex == 0) return widget.words;
    if (_filterIndex == 1) {
      return widget.words.where((w) => w.word.isKnown).toList();
    }
    return widget.words.where((w) => !w.word.isKnown).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredWords;

    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Center(
          child: _FilterToggle(
            selectedIndex: _filterIndex,
            onSelected: (index) => setState(() => _filterIndex = index),
          ),
        ),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(AppStrings.noWordsForFilter),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => Divider(
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
            itemBuilder: (ctx, i) {
              final w = filtered[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  w.word.text,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${w.localFrequency}x',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusButton(
                      isKnown: w.word.isKnown,
                      onToggle: () => widget.onToggleStatus?.call(w),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text(AppStrings.all), icon: Icon(Icons.list)),
        ButtonSegment(
            value: 1,
            label: Text(AppStrings.known),
            icon: Icon(Icons.check_circle_outline)),
        ButtonSegment(
            value: 2, label: Text(AppStrings.unknownLabel), icon: Icon(Icons.help_outline)),
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

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.isKnown,
    required this.onToggle,
  });

  final bool isKnown;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isKnown
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isKnown 
                ? AppColors.secondary.withValues(alpha: 0.2) 
                : AppColors.error.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isKnown ? Icons.check_circle : Icons.help_outline,
              size: 14,
              color: isKnown ? AppColors.secondary : AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              isKnown ? AppStrings.known : AppStrings.unknownLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isKnown ? AppColors.secondary : AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
