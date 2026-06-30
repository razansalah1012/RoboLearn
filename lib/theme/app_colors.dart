import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color cranberry = Color(0xFF8C2433);
  static const Color cranberryDeep = Color(0xFF651927);
  static const Color plum = Color(0xFF7A4654);
  static const Color roseTint = Color(0xFFF7E8EA);

  // Improved Neutral Colors
  static const Color beige = Color(0xFFFAF7F1); // warm app background
  static const Color taupe = Color(0xFF6D5B50); // readable neutral text
  static const Color ivory = Color(0xFFFFFCF8); // cleaner soft card color

  // Extra Utility Colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = ivory;
  static const Color headerBackground = cranberry;

  // Shadows
  static Color softShadowColor() => cranberry.withAlpha(24);

  static Color cardShadowColor() => cranberryDeep.withAlpha(14);

  static Color hoverShadowColor() => cranberry.withAlpha(42);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cranberry, plum],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [cranberry, plum, cranberryDeep],
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
    colors: [plum, roseTint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
