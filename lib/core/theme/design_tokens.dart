import 'package:flutter/material.dart';

/// Centralized design tokens for the application.
/// Follows Material 3 principles with a custom premium touch.
abstract final class AppTokens {
  // Spacing
  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space24 = 24.0;
  static const space32 = 32.0;
  static const space48 = 48.0;
  static const space64 = 64.0;

  // Radius
  static const radius4 = 4.0;
  static const radius8 = 8.0;
  static const radius12 = 12.0;
  static const radius16 = 16.0;
  static const radius24 = 24.0;
  static const radius32 = 32.0;
  static const radiusFull = 999.0;
  static const defaultRadius = radius16;

  // Shadows
  static List<BoxShadow> get shadowLow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowSubtle => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowHigh => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // Animation Durations
  static const durMicro = Duration(milliseconds: 100);
  static const durFast = Duration(milliseconds: 200);
  static const durNormal = Duration(milliseconds: 350);
  static const durSlow = Duration(milliseconds: 600);
  static const dualFast = Duration(milliseconds: 150);

  // Layout Constraints
  static const maxContentWidth = 1200.0;
  static const maxMobileWidth = 600.0;
}
