import 'package:flutter/material.dart';
import 'package:word_flow/features/words/domain/entities/script_analysis.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';
import 'package:word_flow/features/words/presentation/widgets/results_section.dart';
import 'package:word_flow/features/words/presentation/widgets/script_input_section.dart';
import 'package:word_flow/features/words/presentation/widgets/workspace_header.dart';

class WorkspaceBody extends StatelessWidget {

  const WorkspaceBody({
    super.key,
    required this.state,
    required this.controller,
    required this.onAnalyze,
    required this.onClear,
  });
  final WorkspaceState state;
  final TextEditingController controller;
  final VoidCallback onAnalyze;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final summary = state.maybeMap(
      results: (s) => s.summary,
      orElse: () => const ScriptSummary.empty(),
    );
    final isProcessing = state.maybeMap(
      processing: (_) => true,
      orElse: () => false,
    );

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
