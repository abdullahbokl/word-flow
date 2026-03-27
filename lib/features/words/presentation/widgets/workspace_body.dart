import 'package:flutter/material.dart';
import '../../../../core/utils/script_processor.dart';
import '../../../../core/utils/script_analysis.dart';
import '../cubit/workspace_state.dart';
import 'results_section.dart';
import 'script_input_section.dart';
import 'workspace_header.dart';

class WorkspaceBody extends StatelessWidget {
  final WorkspaceState state;
  final ScriptSummary summary;
  final List<ProcessedWord> words;
  final Set<String> pendingWordTexts;
  final bool isProcessing;
  final TextEditingController controller;
  final VoidCallback onAnalyze;
  final VoidCallback onClear;

  const WorkspaceBody({
    super.key,
    required this.state,
    required this.summary,
    required this.words,
    required this.pendingWordTexts,
    required this.isProcessing,
    required this.controller,
    required this.onAnalyze,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth > 980 ? 980 : constraints.maxWidth,
            ),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  sliver: SliverToBoxAdapter(
                    child: WorkspaceHeader(summary: summary),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: ScriptInputSection(
                      controller: controller,
                      isProcessing: isProcessing,
                      onAnalyze: onAnalyze,
                      onClear: onClear,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  sliver: ResultsSection(
                    state: state,
                    words: words,
                    isProcessing: isProcessing,
                    pendingWordTexts: pendingWordTexts,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
