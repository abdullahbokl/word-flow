import 'package:flutter/material.dart';

/// Typography system using bundled Outfit font for offline-first support.
/// All text styles use the 'Outfit' font family which is bundled in assets/fonts/
class AppTextStyles {
  static TextTheme textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: _headline(colorScheme.onSurface, 50, 1.02, -1.4, 700),
      displayMedium: _headline(colorScheme.onSurface, 40, 1.05, -1.0, 700),
      headlineLarge: _headline(colorScheme.onSurface, 32, 1.1, -0.8, 700),
      headlineMedium: _headline(colorScheme.onSurface, 26, 1.12, -0.4, 650),
      titleLarge: _headline(colorScheme.onSurface, 22, 1.15, -0.3, 650),
      titleMedium: _headline(colorScheme.onSurface, 18, 1.2, -0.1, 600),
      bodyLarge: _body(colorScheme.onSurface, 16, 1.6, 0),
      bodyMedium: _body(colorScheme.onSurfaceVariant, 14, 1.5, 0),
      bodySmall: _body(colorScheme.onSurfaceVariant, 12, 1.45, 0.1),
      labelLarge: _body(colorScheme.onSurface, 14, 1.15, 0.2, 600),
      labelMedium: _body(colorScheme.onSurfaceVariant, 12, 1.15, 0.4, 600),
    );
  }

  static TextStyle _headline(
    Color color,
    double size,
    double height,
    double letterSpacing,
    int weight,
  ) {
    return TextStyle(
      fontFamily: 'Outfit',
      color: color,
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
      fontWeight: _fontWeight(weight),
    );
  }

  static TextStyle _body(
    Color color,
    double size,
    double height,
    double letterSpacing, [
    int weight = 400,
  ]) {
    return TextStyle(
      fontFamily: 'Outfit',
      color: color,
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
      fontWeight: _fontWeight(weight),
    );
  }

  static FontWeight _fontWeight(int weight) {
    return switch (weight) {
      400 => FontWeight.w400,
      500 => FontWeight.w500,
      600 => FontWeight.w600,
      650 => FontWeight.w700,
      700 => FontWeight.w700,
      _ => FontWeight.w400,
    };
  }
}
