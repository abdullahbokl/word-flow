import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme get textTheme {
    // We use Lexend for headlines for a modern, friendly look
    // and Inter for body text for maximum legibility.
    final displayBase = GoogleFonts.lexendTextTheme();
    final bodyBase = GoogleFonts.interTextTheme();

    return bodyBase.copyWith(
      displayLarge: displayBase.displayLarge,
      displayMedium: displayBase.displayMedium,
      displaySmall: displayBase.displaySmall,
      headlineLarge: displayBase.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: displayBase.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineSmall: displayBase.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: displayBase.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: displayBase.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: displayBase.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: bodyBase.bodyLarge?.copyWith(
        height: 1.5,
      ),
      bodyMedium: bodyBase.bodyMedium?.copyWith(
        height: 1.4,
      ),
      bodySmall: bodyBase.bodySmall,
      labelLarge: bodyBase.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}
