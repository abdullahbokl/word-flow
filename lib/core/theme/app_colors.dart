import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand / Core
  static const primary = Color(0xFF1565C0);
  static const secondary = Color(0xFF00BFA5);
  static const accent = Color(0xFF7C4DFF);

  // Semantic
  static const success = Color(0xFF43A047);
  static const error = Color(0xFFD32F2F);
  static const warning = Color(0xFFFFA000);
  static const info = Color(0xFF1976D2);

  // Status-specific (Lexicon context)
  static const statusKnown = Color(0xFF2E7D32);
  static const statusLearning = Color(0xFFF9A825);
  static const statusUnknown = Color(0xFFD84315);

  // Light Color Scheme
  static ColorScheme get lightScheme => ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: const Color(0xFFF8F9FC),
        surfaceContainerLowest: Colors.white,
        onSurface: const Color(0xFF1A1C20),
        onSurfaceVariant: const Color(0xFF44474E),
        outline: const Color(0xFF74777F),
        error: error,
      );

  // Dark Color Scheme
  static ColorScheme get darkScheme => ColorScheme.fromSeed(
        seedColor: primary,
        primary: const Color(0xFFAEC6FF),
        secondary: const Color(0xFF80CBC4),
        tertiary: const Color(0xFFD1C4E9),
        surface: const Color(0xFF0F1117),
        surfaceContainerLowest: const Color(0xFF1E2028),
        onSurface: const Color(0xFFE2E2E6),
        onSurfaceVariant: const Color(0xFFC4C6D0),
        outline: const Color(0xFF8E9099),
        error: const Color(0xFFFFB4AB),
        brightness: Brightness.dark,
      );
}
