import 'package:flutter/material.dart';
import 'package:word_flow/core/widgets/app_loader.dart';

class ProcessingView extends StatelessWidget {
  const ProcessingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          AppLoader(color: Theme.of(context).colorScheme.primary),
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
