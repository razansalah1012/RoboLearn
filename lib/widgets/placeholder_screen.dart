import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.orbitron(fontSize: 16)),
        backgroundColor: AppColors.cranberry,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.taupe.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              "Coming Soon",
              style: GoogleFonts.orbitron(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.cranberry,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "The $title module is under construction.",
              style: GoogleFonts.exo2(color: AppColors.taupe),
            ),
          ],
        ),
      ),
    );
  }
}
