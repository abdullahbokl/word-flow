import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppColorScheme {
  static ColorScheme build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: isDark ? AppColors.textDark : AppColors.textLight,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onSurface: isDark ? AppColors.textDark : AppColors.textLight,
      surfaceContainerHighest: isDark
          ? AppColors.surfaceVariantDark
          : AppColors.surfaceVariantLight,
      onSurfaceVariant: isDark
          ? AppColors.textMutedDark
          : AppColors.textMutedLight,
      outline: isDark ? AppColors.borderDark : AppColors.borderLight,
      outlineVariant: isDark ? AppColors.borderDark : AppColors.borderLight,
      error: AppColors.error,
      onError: Colors.white,
    );
  }
}
