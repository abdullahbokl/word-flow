import 'package:flutter/material.dart';

import 'package:lexitrack/core/common/models/word_with_local_freq.dart';
import 'package:lexitrack/core/constants/app_strings.dart';
import 'package:lexitrack/core/widgets/word_list_section_filter_toggle.dart';
import 'package:lexitrack/core/widgets/word_list_section_status_button.dart';

class WordListSection extends StatefulWidget {
  const WordListSection({
    required this.words, super.key,
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
            child: WordListSectionFilterToggle(
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
                      WordListSectionStatusButton(
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
