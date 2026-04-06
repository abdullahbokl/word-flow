import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF42A5F5);
  static const primaryDark = Color(0xFF0D47A1);
  static const secondary = Color(0xFF00BFA5);

// Semantic
  static const known = Color(0xFF2E7D32);
  static const knownSurface = Color(0xFFE8F5E9);
  static const unknown = Color(0xFFE65100);
  static const unknownSurface = Color(0xFFFFF3E0);
  static const error = Color(0xFFC62828);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);

  // Light palette
  static const lightBg = Color(0xFFF8F9FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE0E3E8);
  static const lightTextPrimary = Color(0xFF1A1C20);
  static const lightTextSecondary = Color(0xFF5F6368);

  // Dark palette
  static const darkBg = Color(0xFF0F1117);
  static const darkSurface = Color(0xFF1E2028);
  static const darkBorder = Color(0xFF33363D);
  static const darkTextPrimary = Color(0xFFE8EAED);
  static const darkTextSecondary = Color(0xFF9AA0A6);
}
