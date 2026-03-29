import 'package:flutter/material.dart';
import 'package:word_flow/core/utils/script_processor.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';
import 'package:word_flow/features/words/presentation/widgets/results_state_switcher.dart';
import 'package:word_flow/features/words/presentation/widgets/analysis_results_list.dart';

class ResultsSection extends StatefulWidget {

  const ResultsSection({
    super.key,
    required this.state,
    required this.words,
    required this.isProcessing,
    required this.pendingWordTexts,
  });
  final WorkspaceState state;
  final List<ProcessedWord> words;
  final bool isProcessing;
  final Set<String> pendingWordTexts;

  @override
  State<ResultsSection> createState() => _ResultsSectionState();
}

class _ResultsSectionState extends State<ResultsSection> {
  bool _isKnownExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        ResultsStateSwitcher(
          state: widget.state,
          words: widget.words,
          isProcessing: widget.isProcessing,
        ),
        ...widget.state.maybeWhen(
          processing: () => _buildList(widget.words, [], true),
          results: (all, unknown, known) => _buildList(unknown, known, false),
          orElse: () => [],
        ),
      ],
    );
  }

  List<Widget> _buildList(List<ProcessedWord> unknown, List<ProcessedWord> known, bool isRefreshing) {
    return [
      AnalysisResultsList(
        unknownWords: unknown,
        knownWords: known,
        isRefreshing: isRefreshing,
        isProcessing: widget.isProcessing,
        isKnownExpanded: _isKnownExpanded,
        pendingWordTexts: widget.pendingWordTexts,
        onToggleKnown: () => setState(() => _isKnownExpanded = !_isKnownExpanded),
      ),
    ];
  }
}
