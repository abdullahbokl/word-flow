import 'package:flutter/material.dart';
import 'package:word_flow/core/widgets/app_button.dart';
import 'package:word_flow/core/widgets/section_card.dart';
import 'package:word_flow/features/words/presentation/widgets/script_input_field.dart';

class ScriptInputSection extends StatelessWidget {

  const ScriptInputSection({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.onAnalyze,
    required this.onClear,
  });
  final TextEditingController controller;
  final bool isProcessing;
  final VoidCallback onAnalyze;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Paste your text',
      subtitle: 'Drop in a script, article, or study note. Large blocks stay smooth.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScriptInputField(controller: controller),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: AppButton(
                  label: isProcessing ? 'Analyzing...' : 'Analyze script',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: isProcessing,
                  onPressed: onAnalyze,
                ),
              ),
              SizedBox(
                width: 180,
                child: AppButton(
                  label: 'Clear text',
                  icon: Icons.clear_all_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: onClear,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
