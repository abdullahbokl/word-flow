import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_cubit.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_state.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/results_state_switcher.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/analysis_results_list.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/analysis_results_header.dart';

class ResultsSection extends StatefulWidget {
  const ResultsSection({super.key});

  @override
  State<ResultsSection> createState() => _ResultsSectionState();
}

class _ResultsSectionState extends State<ResultsSection> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceCubit, WorkspaceState>(
      builder: (context, state) {
        return SliverMainAxisGroup(
          slivers: [
            state.maybeMap(
              results: (resultsState) => SliverToBoxAdapter(
                child: AnalysisResultsHeader(
                  // We still provide progress state but avoid key reset
                  isProcessing: resultsState.pendingKnownWords.isNotEmpty,
                ),
              ),
              orElse: () => ResultsStateSwitcher(
                key: const ValueKey('results_switcher'),
                state: state,
                words: const [],
                isProcessing: state.maybeMap(
                  processing: (_) => true,
                  orElse: () => false,
                ),
              ),
            ),
            state.maybeMap(
              results: (resultsState) {
                final unknown = resultsState.words
                    .where((w) => !w.isKnown)
                    .toList();
                final known = resultsState.words
                    .where((w) => w.isKnown)
                    .toList();

                return AnalysisResultsList(
                  // Stabilized key to allow AnimatedList to persist and animate.
                  // We only force a reset if the revision changes (new analysis).
                  key: ValueKey('results_list_stable_${resultsState.revision}'),
                  unknownWords: unknown,
                  knownWords: known,
                  isRefreshing: resultsState.pendingKnownWords.isNotEmpty,
                  isProcessing: resultsState.pendingKnownWords.isNotEmpty,
                  pendingWordTexts: resultsState.pendingKnownWords,
                );
              },
              orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        );
      },
    );
  }
}
