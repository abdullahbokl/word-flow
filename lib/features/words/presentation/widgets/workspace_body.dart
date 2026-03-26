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
  final TextEditingController controller;
  final VoidCallback onAnalyze;
  final VoidCallback onClear;
  final Function(String wordText) onToggle;

  const WorkspaceBody({
    super.key,
    required this.state,
    required this.summary,
    required this.controller,
    required this.onAnalyze,
    required this.onClear,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final words = state.map(
      initial: (_) => <ProcessedWord>[],
      processing: (_) => <ProcessedWord>[],
      results: (res) => res.words,
      error: (_) => <ProcessedWord>[],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth > 980 ? 980 : constraints.maxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                WorkspaceHeader(
                  summary: summary,
                ),
                const SizedBox(height: 18),
                ScriptInputSection(
                  controller: controller,
                  isProcessing: state.maybeMap(
                    processing: (_) => true,
                    orElse: () => false,
                  ),
                  onAnalyze: onAnalyze,
                  onClear: onClear,
                ),
                const SizedBox(height: 18),
                ResultsSection(
                  state: state,
                  words: words,
                  onToggle: onToggle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
