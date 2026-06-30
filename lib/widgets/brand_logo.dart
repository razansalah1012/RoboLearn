import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class BrandLogoMark extends StatelessWidget {
  final double size;
  final bool showHalo;

  const BrandLogoMark({super.key, this.size = 72, this.showHalo = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.ivory,
        border: Border.all(color: AppColors.cranberry.withAlpha(30)),
        boxShadow: showHalo
            ? [
                BoxShadow(
                  color: AppColors.cranberry.withAlpha(28),
                  blurRadius: size * 0.32,
                  offset: Offset(0, size * 0.10),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(size * 0.16),
      child: Image.asset('assets/logo.png', fit: BoxFit.contain),
    );
  }
}

class BrandLogoLockup extends StatelessWidget {
  final double markSize;
  final double titleSize;
  final bool centered;

  const BrandLogoLockup({
    super.key,
    this.markSize = 84,
    this.titleSize = 30,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        BrandLogoMark(size: markSize),
        SizedBox(height: markSize * 0.18),
        Text(
          'RoboLearn',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.orbitron(
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            color: AppColors.cranberry,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Robotics Learning System',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.exo2(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.taupe,
          ),
        ),
      ],
    );

    return centered ? Center(child: column) : column;
  }
}
