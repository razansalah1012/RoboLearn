import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color cranberry = Color(0xFF3F1116);
  static const Color plum = Color(0xFF64343C);

  // Improved Neutral Colors
  static const Color beige = Color(0xFFF8F6F2); // upgraded premium background
  static const Color taupe = Color(0xFF7A6856); // stronger readable brown
  static const Color ivory = Color(0xFFFFFAF7); // cleaner soft card color

  // Extra Utility Colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = ivory;
  static const Color headerBackground = cranberry;

  // Shadows
  static Color softShadowColor() =>
      const Color(0xFF8B1538).withAlpha(20);

  static Color cardShadowColor() =>
      Colors.black.withAlpha(13);

  static Color hoverShadowColor() =>
      const Color(0xFF8B1538).withAlpha(38);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cranberry, plum],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neutralGradient = LinearGradient(
    colors: [taupe, beige],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [ivory, beige],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [plum, taupe],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}