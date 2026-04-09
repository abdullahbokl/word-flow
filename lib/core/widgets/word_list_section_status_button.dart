import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

class WordListSectionStatusButton extends StatelessWidget {
  const WordListSectionStatusButton({
    required this.isKnown,
    required this.onToggle,
    super.key,
  });

  final bool isKnown;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isKnown
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isKnown
                ? AppColors.secondary.withValues(alpha: 0.2)
                : AppColors.error.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isKnown ? Icons.check_circle : Icons.help_outline,
              size: 14,
              color: isKnown ? AppColors.secondary : AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              isKnown ? AppStrings.known : AppStrings.unknownLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isKnown ? AppColors.secondary : AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
