import 'package:flutter/material.dart';

import '../common/models/word_with_local_freq.dart';
import '../constants/app_strings.dart';
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
  int _filterIndex = 0;

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

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: Center(
            child: _FilterToggle(
              selectedIndex: _filterIndex,
              onSelected: (index) => setState(() => _filterIndex = index),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        if (filtered.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(AppStrings.noWordsForFilter),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, index) {
                if (index.isOdd) {
                  return Divider(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    height: 1,
                  );
                }

                final wordIndex = index ~/ 2;
                final w = filtered[wordIndex];
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
              childCount: filtered.length * 2 - 1,
            ),
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
