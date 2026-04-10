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
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) {
                  final w = filtered[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w.word.text,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              if (w.word.meaning != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  w.word.meaning!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '${w.localFrequency}x',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        WordListSectionStatusButton(
                          isKnown: w.word.isKnown,
                          onToggle: () => widget.onToggleStatus?.call(w),
                        ),
                      ],
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}
