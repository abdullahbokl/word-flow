import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/word_learning/domain/entities/script_analysis.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_state.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_cubit.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/results_section.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/script_input_widget.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/workspace_header.dart';
import 'package:word_flow/core/widgets/error_state_widget.dart';
import 'package:word_flow/core/errors/failure_mapper.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';

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
                  sliver: BlocSelector<WorkspaceCubit, WorkspaceState,
                      ({bool isProcessing, double progress, int totalWords})>(
                    selector: (state) => state.maybeMap(
                      processing: (s) => (
                        isProcessing: true,
                        progress: s.progress,
                        totalWords: s.totalWords,
                      ),
                      orElse: () => (
                        isProcessing: false,
                        progress: 0.0,
                        totalWords: 0,
                      ),
                    ),
                    builder: (context, processingVm) => SliverToBoxAdapter(
                      child: ScriptInputWidget(
                        controller: controller,
                        isProcessing: processingVm.isProcessing,
                        progress: processingVm.progress,
                        totalWords: processingVm.totalWords,
                      ),
                    ),
                  ),
                ),
                BlocBuilder<WorkspaceCubit, WorkspaceState>(
                  buildWhen: (p, c) => c.maybeMap(
                    results: (_) => true,
                    error: (_) => true,
                    orElse: () => false,
                  ) || p.maybeMap(
                    results: (_) => true,
                    error: (_) => true,
                    orElse: () => false,
                  ),
                  builder: (context, state) {
                    return state.maybeMap(
                      results: (_) => const SliverPadding(
                        padding: EdgeInsets.fromLTRB(20, 18, 20, 28),
                        sliver: ResultsSection(),
                      ),
                      error: (s) {
                        final isAuth = s.failure is AuthFailure;
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                            child: ErrorStateWidget(
                              title: s.failure?.title ?? 'Analysis Failed',
                              message: s.failure?.friendlyMessage ?? s.message,
                              icon: s.failure?.icon ?? Icons.analytics_rounded,
                              onRetry: isAuth
                                  ? null
                                  : () {
                                      final userId = context.read<AuthCubit>().currentUserId;
                                      context.read<WorkspaceCubit>().analyze(controller.text, userId: userId);
                                    },
                              actionLabel: isAuth ? 'Sign In Again' : null,
                              onAction: isAuth ? () => context.read<AuthCubit>().logOut() : null,
                            ),
                          ),
                        );
                      },
                      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
