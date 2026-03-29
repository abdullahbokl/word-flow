import 'package:flutter/material.dart';
import 'package:word_flow/core/utils/script_processor.dart';
import 'package:word_flow/features/words/presentation/widgets/word_results_list.dart';
import 'package:word_flow/features/words/presentation/widgets/known_words_header.dart';

class AnalysisResultsList extends StatelessWidget {

  const AnalysisResultsList({
    super.key,
    required this.unknownWords,
    required this.knownWords,
    required this.isRefreshing,
    required this.isProcessing,
    required this.isKnownExpanded,
    required this.pendingWordTexts,
    required this.onToggleKnown,
  });
  final List<ProcessedWord> unknownWords;
  final List<ProcessedWord> knownWords;
  final bool isRefreshing;
  final bool isProcessing;
  final bool isKnownExpanded;
  final Set<String> pendingWordTexts;
  final VoidCallback onToggleKnown;

  @override
  Widget build(BuildContext context) {
    if (unknownWords.isEmpty && knownWords.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverMainAxisGroup(
      slivers: [
        if (isRefreshing) _RefreshingIndicator(scheme: scheme, textTheme: textTheme),
        if (unknownWords.isNotEmpty) ...[
          _SectionTitle(title: 'Unknown (${unknownWords.length})', color: scheme.primary),
          WordResultsList(
            words: unknownWords,
            pendingWordTexts: pendingWordTexts,
            enabled: !isProcessing,
          ),
        ],
        if (unknownWords.isNotEmpty && knownWords.isNotEmpty) _Divider(),
        if (knownWords.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: KnownWordsHeader(
              count: knownWords.length,
              isExpanded: isKnownExpanded,
              onToggle: onToggleKnown,
            ),
          ),
          if (isKnownExpanded)
            WordResultsList(
              words: knownWords,
              pendingWordTexts: pendingWordTexts,
              enabled: !isProcessing,
            ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _RefreshingIndicator extends StatelessWidget {
  const _RefreshingIndicator({required this.scheme, required this.textTheme});
  final ColorScheme scheme;
  final TextTheme textTheme;
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(minHeight: 3, borderRadius: BorderRadius.circular(999)),
              const SizedBox(height: 8),
              Text('Refreshing results...', style: textTheme.labelSmall?.copyWith(color: scheme.primary)),
            ],
          ),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()));
}
