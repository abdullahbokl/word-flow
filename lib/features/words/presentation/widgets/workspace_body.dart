import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/words/domain/entities/script_analysis.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_cubit.dart';
import 'package:word_flow/features/words/presentation/widgets/results_section.dart';
import 'package:word_flow/features/words/presentation/widgets/script_input_section.dart';
import 'package:word_flow/features/words/presentation/widgets/workspace_header.dart';

class WorkspaceBody extends StatelessWidget {

  const WorkspaceBody({
    super.key,
    required this.controller,
  });
  final TextEditingController controller;

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
                  sliver: BlocSelector<WorkspaceCubit, WorkspaceState, ScriptSummary>(
                    selector: (state) => state.maybeMap(
                      results: (s) => s.summary,
                      orElse: () => const ScriptSummary.empty(),
                    ),
                    builder: (context, summary) => SliverToBoxAdapter(
                      child: WorkspaceHeader(summary: summary),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: BlocSelector<WorkspaceCubit, WorkspaceState, bool>(
                    selector: (state) => state.maybeMap(
                      processing: (_) => true,
                      orElse: () => false,
                    ),
                    builder: (context, isProcessing) => SliverToBoxAdapter(
                      child: ScriptInputSection(
                        controller: controller,
                        isProcessing: isProcessing,
                      ),
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 28),
                  sliver: ResultsSection(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
