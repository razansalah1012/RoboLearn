import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Border Radius Constants
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 32.0; // Optimized for rounded headers
  static const double radiusPill = 50.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.cranberry,
      scaffoldBackgroundColor: AppColors.beige,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.cranberry,
        secondary: AppColors.plum,
        surface: AppColors.ivory,
        onPrimary: AppColors.ivory,
        onSecondary: AppColors.ivory,
        onSurface: AppColors.cranberry,
        error: Colors.redAccent,
        onError: Colors.white,
      ),

      // Typography
      textTheme: TextTheme(
        // Hero Title
        displayLarge: GoogleFonts.orbitron(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColors.cranberry,
        ),
        // Section Titles
        displayMedium: GoogleFonts.orbitron(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.cranberry,
        ),
        // App Title
        displaySmall: GoogleFonts.orbitron(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.cranberry,
        ),
        // Card Titles
        titleLarge: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.cranberry,
        ),
        // Body Text
        bodyLarge: GoogleFonts.exo2(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.taupe,
        ),
        bodyMedium: GoogleFonts.exo2(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.taupe,
        ),
        // Navigation / Labels
        labelLarge: GoogleFonts.exo2(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.cranberry,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cranberry,
        foregroundColor: AppColors.ivory,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.ivory,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.ivory,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.cardShadowColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(color: AppColors.plum.withAlpha(18)),
        ),
      ),

      // Input Decoration (Text Fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ivory,
        labelStyle: GoogleFonts.exo2(color: AppColors.taupe, fontSize: 16),
        hintStyle: GoogleFonts.exo2(
          color: AppColors.taupe.withAlpha(150),
          fontSize: 16,
        ),
        prefixIconColor: AppColors.plum,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.plum.withAlpha(28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.cranberry, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cranberry,
          foregroundColor: AppColors.ivory,
          textStyle: GoogleFonts.exo2(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          elevation: 0,
          shadowColor: AppColors.softShadowColor(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Text Button Theme (Forms, Links)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.plum,
          textStyle: GoogleFonts.exo2(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.roseTint,
        selectedColor: AppColors.cranberry,
        checkmarkColor: AppColors.ivory,
        labelStyle: GoogleFonts.exo2(
          color: AppColors.plum,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: GoogleFonts.exo2(
          color: AppColors.ivory,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: AppColors.plum.withAlpha(24)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
      ),
    );
  }
}
