import 'package:flutter/material.dart';
import 'package:word_flow/features/words/presentation/widgets/analysis_chip.dart';

class AnalysisResultsHeader extends StatelessWidget {

  const AnalysisResultsHeader({
    super.key,
    required this.isProcessing,
  });
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Analysis results', style: textTheme.titleMedium),
                Text(
                  'Recognized and unrecognized words',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                    height: 1.4,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: const Color.fromRGBO(244, 238, 230, 1),
                  ),
                ),
              ],
            ),
          ),
          AnalysisChip(
            icon: isProcessing
                ? Icons.hourglass_top_rounded
                : Icons.check_circle_rounded,
            label: isProcessing ? 'Refreshing' : 'Auto-saved',
          ),
        ],
      ),
    );
  }
}
