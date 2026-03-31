import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/widgets/app_button.dart';
import 'package:word_flow/core/widgets/section_card.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/word_learning/presentation/blocs/workspace_cubit.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/script_input_field.dart';
import 'package:word_flow/features/word_learning/presentation/widgets/script_processing_progress_overlay.dart';

class ScriptInputWidget extends StatelessWidget {
  const ScriptInputWidget({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.progress,
    required this.totalWords,
  });

  final TextEditingController controller;
  final bool isProcessing;
  final double progress;
  final int totalWords;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Paste your text',
      subtitle:
          'Drop in a script, article, or study note. Large blocks stay smooth.',
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
                  isLoading: false,
                  onPressed: isProcessing
                      ? null
                      : () {
                          final userId = context
                              .read<AuthCubit>()
                              .currentUserId;
                          context.read<WorkspaceCubit>().analyze(
                            controller.text,
                            userId: userId,
                          );
                        },
                ),
              ),
              SizedBox(
                width: 180,
                child: AppButton(
                  label: 'Clear text',
                  icon: Icons.clear_all_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: isProcessing
                      ? null
                      : () {
                          controller.clear();
                          context.read<WorkspaceCubit>().analyze('');
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ScriptProcessingProgressOverlay(
            isProcessing: isProcessing,
            progress: progress,
            totalWords: totalWords,
          ),
        ],
      ),
    );
  }
}
