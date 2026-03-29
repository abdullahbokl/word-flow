import 'package:flutter/material.dart';
import 'package:word_flow/features/words/domain/entities/processed_word.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';
import 'package:word_flow/features/words/presentation/widgets/results_state_switcher.dart';
import 'package:word_flow/features/words/presentation/widgets/analysis_results_list.dart';

class ResultsSection extends StatefulWidget {

  const ResultsSection({
    super.key,
    required this.state,
  });
  final WorkspaceState state;

  @override
  State<ResultsSection> createState() => _ResultsSectionState();
}

class _ResultsSectionState extends State<ResultsSection> {
  bool _isKnownExpanded = false;

  @override
  Widget build(BuildContext context) {
    final words = widget.state.maybeMap(
      results: (s) => s.words,
      orElse: () => const <ProcessedWord>[],
    );
    final pendingWordTexts = widget.state.maybeMap(
      results: (s) => s.pendingKnownWords,
      orElse: () => const <String>{},
    );
    final isProcessing = widget.state.maybeMap(
      processing: (_) => true,
      orElse: () => false,
    );

    return SliverMainAxisGroup(
      slivers: [
        ResultsStateSwitcher(
          state: widget.state,
          words: words,
          isProcessing: isProcessing,
        ),
        ...widget.state.maybeWhen(
          processing: () => _buildList(words, const <ProcessedWord>[], true, pendingWordTexts, isProcessing),
          results: (all, _, __, ___) {
            final unknown = all.where((w) => !w.isKnown).toList(growable: false);
            final known = all.where((w) => w.isKnown).toList(growable: false);
            return _buildList(unknown, known, false, pendingWordTexts, isProcessing);
          },
          orElse: () => [],
        ),
      ],
    );
  }

  List<Widget> _buildList(
    List<ProcessedWord> unknown,
    List<ProcessedWord> known,
    bool isRefreshing,
    Set<String> pendingWordTexts,
    bool isProcessing,
  ) {
    return [
      AnalysisResultsList(
        unknownWords: unknown,
        knownWords: known,
        isRefreshing: isRefreshing,
        isProcessing: isProcessing,
        isKnownExpanded: _isKnownExpanded,
        pendingWordTexts: pendingWordTexts,
        onToggleKnown: () => setState(() => _isKnownExpanded = !_isKnownExpanded),
      ),
    ];
  }
}
