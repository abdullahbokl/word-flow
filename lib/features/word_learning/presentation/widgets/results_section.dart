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
                // Using uniquely identifiable keys for every state
                child: AnalysisResultsHeader(
                  key: ValueKey('analysis_header_${resultsState.revision}'),
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
                    .toList(growable: false);
                final known = resultsState.words
                    .where((w) => w.isKnown)
                    .toList(growable: false);

                return AnalysisResultsList(
                  // Key incorporates revision/pending count to ensure fresh building
                  // when fundamental state changes, avoiding stale list state
                  key: ValueKey(
                    'results_list_${resultsState.revision}_${resultsState.pendingKnownWords.length}',
                  ),
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
