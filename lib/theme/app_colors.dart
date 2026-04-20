import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (5-Color Palette)
  static const Color cranberry = Color(0xFF3F1116);
  static const Color beige = Color(0xFFFEEFDC);
  static const Color plum = Color(0xFF64343C);
  static const Color taupe = Color(0xFF907960);
  static const Color ivory = Color(0xFFFFF1E9);

  // Background Colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = pureWhite;
  static const Color headerBackground = cranberry;
  
  // Shadows & Depth (using with opacity where requested)
  // Soft Shadow: 0 4px 20px rgba(139, 21, 56, 0.08) -> RGB(139, 21, 56) is roughly #8B1538 (a cranberry/plum shade)
  static Color softShadowColor() => const Color(0xFF8B1538).withAlpha(20); // 0.08 * 255 ≈ 20
  // Card Shadow: 0 2px 15px rgba(0, 0, 0, 0.05)
  static Color cardShadowColor() => Colors.black.withAlpha(13); // 0.05 * 255 ≈ 13
  // Hover Shadow: 0 8px 25px rgba(139, 21, 56, 0.15)
  static Color hoverShadowColor() => const Color(0xFF8B1538).withAlpha(38); // 0.15 * 255 ≈ 38

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
