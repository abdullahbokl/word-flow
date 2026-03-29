import 'package:flutter/material.dart';
import 'package:word_flow/features/words/domain/entities/processed_word.dart';
import 'package:word_flow/features/words/presentation/widgets/word_results_list.dart';
import 'package:word_flow/features/words/presentation/widgets/known_words_header.dart';

class AnalysisResultsList extends StatefulWidget {

  const AnalysisResultsList({
    super.key,
    required this.unknownWords,
    required this.knownWords,
    required this.isRefreshing,
    required this.isProcessing,
    required this.pendingWordTexts,
  });
  final List<ProcessedWord> unknownWords;
  final List<ProcessedWord> knownWords;
  final bool isRefreshing;
  final bool isProcessing;
  final Set<String> pendingWordTexts;

  @override
  State<AnalysisResultsList> createState() => _AnalysisResultsListState();
}

class _AnalysisResultsListState extends State<AnalysisResultsList> {
  bool _isKnownExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.unknownWords.isEmpty && widget.knownWords.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverMainAxisGroup(
      slivers: [
        if (widget.isRefreshing) _RefreshingIndicator(scheme: scheme, textTheme: textTheme),
        if (widget.unknownWords.isNotEmpty) ...[
          _SectionTitle(title: 'Unknown (${widget.unknownWords.length})', color: scheme.primary),
          WordResultsList(
            words: widget.unknownWords,
            pendingWordTexts: widget.pendingWordTexts,
            enabled: !widget.isProcessing,
          ),
        ],
        if (widget.unknownWords.isNotEmpty && widget.knownWords.isNotEmpty) _Divider(),
        if (widget.knownWords.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: KnownWordsHeader(
              count: widget.knownWords.length,
              isExpanded: _isKnownExpanded,
              onToggle: () => setState(() => _isKnownExpanded = !_isKnownExpanded),
            ),
          ),
          if (_isKnownExpanded)
            WordResultsList(
              words: widget.knownWords,
              pendingWordTexts: widget.pendingWordTexts,
              enabled: !widget.isProcessing,
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
