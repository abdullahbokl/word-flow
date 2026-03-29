import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/features/words/domain/entities/processed_word.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_cubit.dart';
import 'package:word_flow/features/words/presentation/cubit/workspace_state.dart';
import 'package:word_flow/features/words/presentation/widgets/results_state_switcher.dart';
import 'package:word_flow/features/words/presentation/widgets/analysis_results_list.dart';

class ResultsSection extends StatefulWidget {

  const ResultsSection({super.key});

  @override
  State<ResultsSection> createState() => _ResultsSectionState();
}

class _ResultsSectionState extends State<ResultsSection> {
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        BlocBuilder<WorkspaceCubit, WorkspaceState>(
          buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
          builder: (context, state) {
            final words = state.maybeMap(
              results: (s) => s.words,
              orElse: () => const <ProcessedWord>[],
            );
            final isProcessing = state.maybeMap(
              processing: (_) => true,
              orElse: () => false,
            );
            return ResultsStateSwitcher(
              state: state,
              words: words,
              isProcessing: isProcessing,
            );
          },
        ),
        BlocSelector<WorkspaceCubit, WorkspaceState, ({List<ProcessedWord> unknown, List<ProcessedWord> known, bool isRefreshing, Set<String> pendingWordTexts, bool isProcessing})>(
          selector: (state) {
            return state.maybeWhen(
              processing: () => (
                unknown: const <ProcessedWord>[],
                known: const <ProcessedWord>[],
                isRefreshing: true,
                pendingWordTexts: const <String>{},
                isProcessing: true,
              ),
                results: (all, _, pendingKnownWords, __, ___) {
                final unknown = all.where((w) => !w.isKnown).toList(growable: false);
                final known = all.where((w) => w.isKnown).toList(growable: false);
                return (
                  unknown: unknown,
                  known: known,
                  isRefreshing: false,
                  pendingWordTexts: pendingKnownWords,
                  isProcessing: false,
                );
              },
              orElse: () => (
                unknown: const <ProcessedWord>[],
                known: const <ProcessedWord>[],
                isRefreshing: false,
                pendingWordTexts: const <String>{},
                isProcessing: false,
              ),
            );
          },
          builder: (context, data) {
            return AnalysisResultsList(
              unknownWords: data.unknown,
              knownWords: data.known,
              isRefreshing: data.isRefreshing,
              isProcessing: data.isProcessing,
              pendingWordTexts: data.pendingWordTexts,
            );
          },
        ),
      ],
    );
  }
}
