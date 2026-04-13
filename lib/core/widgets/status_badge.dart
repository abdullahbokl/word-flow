import 'package:flutter/material.dart';

import 'package:wordflow/core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.isKnown, super.key});

  final bool isKnown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isKnown
            ? AppColors.statusKnown.withValues(alpha: 0.1)
            : AppColors.statusUnknown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isKnown ? AppColors.statusKnown : AppColors.statusUnknown,
          width: 0.5,
        ),
      ),
      child: Text(
        isKnown ? 'Known' : 'Unknown',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isKnown ? AppColors.statusKnown : AppColors.statusUnknown,
        ),
      ),
    );
  }
}
