import 'package:flutter/material.dart';
import 'package:word_flow/features/word_learning/domain/entities/processed_word.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/word_results_list.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/known_words_header.dart';
import 'package:word_flow/shared/widgets/word_card_shimmer.dart';
import 'package:word_flow/shared/widgets/empty_state.dart';
import 'package:word_flow/core/widgets/section_card.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/analysis_chip.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/analysis_results_list_helpers.dart';

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
      if (widget.isProcessing) {
        return const SliverToBoxAdapter(
          child: SectionCard(
            title: 'Analysis results',
            subtitle: 'New and recognized words from your text.',
            trailing: AnalysisChip(icon: Icons.hourglass_top_rounded, label: 'Analyzing'),
            child: SizedBox(height: 220, child: ShimmerList(count: 4)),
          ),
        );
      }
      return const SliverToBoxAdapter(
        child: SectionCard(
          title: 'Analysis results',
          subtitle: 'New and recognized words from your text.',
          child: EmptyState(
            icon: Icons.auto_awesome_rounded,
            title: 'No words found',
            subtitle: 'Analyze a script to surface unfamiliar words.',
          ),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverMainAxisGroup(
      slivers: [
        if (widget.isRefreshing) RefreshingIndicator(scheme: scheme, textTheme: textTheme),
        if (widget.unknownWords.isNotEmpty) ...[
          SectionTitle(title: 'Unknown (${widget.unknownWords.length})', color: scheme.primary),
          WordResultsList(
            words: widget.unknownWords,
            pendingWordTexts: widget.pendingWordTexts,
            enabled: !widget.isProcessing,
          ),
        ],
        if (widget.unknownWords.isNotEmpty && widget.knownWords.isNotEmpty) const AnalysisDivider(),
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
