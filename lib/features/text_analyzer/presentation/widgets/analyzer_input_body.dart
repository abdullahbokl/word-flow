import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/page_header.dart';

class AnalyzerInputBody extends StatelessWidget {
  const AnalyzerInputBody({
    required this.titleCtrl,
    required this.contentCtrl,
    required this.onAnalyze,
    required this.onPickFile,
    super.key,
  });

  final TextEditingController titleCtrl;
  final TextEditingController contentCtrl;
  final VoidCallback onAnalyze;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(title: AppStrings.textAnalyzer),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppText.title('New Analysis'),
                const SizedBox(height: 16),
                AppTextField(
                  controller: titleCtrl,
                  label: 'Title (Optional)',
                  hint: 'e.g., Short Story, News Article',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: contentCtrl,
                  label: 'Text to Analyze',
                  hint: 'Paste English text here...',
                  maxLines: 15,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: AppStrings.analyzeText,
                  onPressed: onAnalyze,
                  icon: Icons.analytics_outlined,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: AppStrings.uploadTxtFile,
                  onPressed: onPickFile,
                  icon: Icons.upload_file_outlined,
                  variant: AppButtonVariant.outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
