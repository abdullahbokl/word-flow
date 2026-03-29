import 'package:flutter/material.dart';
import 'package:word_flow/core/widgets/empty_state_view.dart';
import 'package:word_flow/core/widgets/section_card.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';
import 'package:word_flow/core/utils/script_processor.dart';
import 'package:word_flow/features/words/presentation/widgets/analysis_chip.dart';
import 'package:word_flow/features/words/presentation/widgets/processing_view.dart';
import 'package:word_flow/features/words/presentation/widgets/analysis_results_header.dart';

class ResultsStateSwitcher extends StatelessWidget {

  const ResultsStateSwitcher({
    super.key,
    required this.state,
    required this.words,
    required this.isProcessing,
  });
  final WorkspaceState state;
  final List<ProcessedWord> words;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return state.maybeMap(
      initial: (_) => const _InitialState(),
      processing: (_) {
        if (words.isNotEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return const _LoadingState();
      },
      error: (error) => _ErrorState(message: error.message),
      results: (_) => SliverToBoxAdapter(
        child: AnalysisResultsHeader(isProcessing: isProcessing),
      ),
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _InitialState extends StatelessWidget {
  const _InitialState();
  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
        child: SectionCard(
          title: 'Analysis results',
          subtitle: 'New and recognized words from your text.',
          child: EmptyStateView(
            icon: Icons.auto_awesome_rounded,
            title: 'Ready when you are',
            message: 'Paste a text block and analyze it to surface unfamiliar words.',
          ),
        ),
      );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
        child: SectionCard(
          title: 'Analysis results',
          subtitle: 'New and recognized words from your text.',
          trailing: AnalysisChip(
            icon: Icons.hourglass_top_rounded,
            label: 'Analyzing',
          ),
          child: ProcessingView(),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: SectionCard(
          title: 'Analysis results',
          subtitle: 'New and recognized words from your text.',
          child: EmptyStateView(
            icon: Icons.error_outline_rounded,
            title: 'Could not analyze the text',
            message: message,
          ),
        ),
      );
}
