import 'package:flutter/material.dart';
import '../../../../core/utils/script_processor.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/section_card.dart';
import '../cubit/workspace_state.dart';
import 'word_results_list.dart';

class ResultsSection extends StatelessWidget {
  final WorkspaceState state;
  final List<ProcessedWord> words;
  final Function(String wordText) onToggle;

  const ResultsSection({
    super.key,
    required this.state,
    required this.words,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Unknown words',
      subtitle: 'Words not found in your known list.',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: state.map(
          initial: (_) => const EmptyStateView(
            icon: Icons.auto_awesome_rounded,
            title: 'Ready when you are',
            message: 'Paste a text block and analyze it to surface unfamiliar words.',
          ),
          processing: (_) => const _ProcessingView(),
          error: (error) => EmptyStateView(
            icon: Icons.error_outline_rounded,
            title: 'Could not analyze the text',
            message: error.message,
          ),
          results: (res) {
            if (res.words.isEmpty) {
              return const EmptyStateView(
                icon: Icons.verified_rounded,
                title: 'Nothing new found',
                message: 'That text does not contain any unfamiliar words right now.',
              );
            }
            return WordResultsList(
              words: res.words,
              onToggle: onToggle,
            );
          },
        ),
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing your text offline-first...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
