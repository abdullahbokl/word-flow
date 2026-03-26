import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_card.dart';
import 'script_input_field.dart';

class ScriptInputSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isProcessing;
  final VoidCallback onAnalyze;
  final VoidCallback onClear;

  const ScriptInputSection({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.onAnalyze,
    required this.onClear,
  });

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
