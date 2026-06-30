import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RoboticsBlueprintVisual extends StatelessWidget {
  final double height;
  final bool dark;

  const RoboticsBlueprintVisual({
    super.key,
    this.height = 140,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _RoboticsBlueprintPainter(dark: dark)),
    );
  }
}

class _RoboticsBlueprintPainter extends CustomPainter {
  final bool dark;

  const _RoboticsBlueprintPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final primary = dark ? AppColors.ivory : AppColors.cranberry;
    final secondary = dark ? AppColors.roseTint : AppColors.plum;
    final faint = primary.withAlpha(dark ? 45 : 28);
    final line = Paint()
      ..color = primary.withAlpha(dark ? 170 : 125)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final thin = Paint()
      ..color = faint
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = secondary.withAlpha(dark ? 40 : 22)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thin);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), thin);
    }

    final base = Offset(size.width * 0.18, size.height * 0.74);
    final shoulder = Offset(size.width * 0.34, size.height * 0.47);
    final elbow = Offset(size.width * 0.55, size.height * 0.36);
    final wrist = Offset(size.width * 0.72, size.height * 0.50);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx, base.dy + 16),
          width: 78,
          height: 28,
        ),
        const Radius.circular(8),
      ),
      fill,
    );

    canvas.drawLine(base, shoulder, line);
    canvas.drawLine(shoulder, elbow, line);
    canvas.drawLine(elbow, wrist, line);

    for (final joint in [base, shoulder, elbow, wrist]) {
      canvas.drawCircle(joint, 13, fill);
      canvas.drawCircle(joint, 13, line);
      canvas.drawCircle(joint, 4, Paint()..color = primary);
    }

    final claw = Path()
      ..moveTo(wrist.dx, wrist.dy)
      ..lineTo(wrist.dx + 34, wrist.dy - 18)
      ..moveTo(wrist.dx, wrist.dy)
      ..lineTo(wrist.dx + 34, wrist.dy + 18)
      ..moveTo(wrist.dx + 34, wrist.dy - 18)
      ..lineTo(wrist.dx + 48, wrist.dy - 28)
      ..moveTo(wrist.dx + 34, wrist.dy + 18)
      ..lineTo(wrist.dx + 48, wrist.dy + 28);
    canvas.drawPath(claw, line);

    final gearCenter = Offset(size.width * 0.86, size.height * 0.28);
    _drawGear(canvas, gearCenter, 22, primary.withAlpha(dark ? 150 : 100));

    final controller = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.70, size.height * 0.70, 78, 38),
      const Radius.circular(12),
    );
    canvas.drawRRect(controller, fill);
    canvas.drawRRect(controller, line..strokeWidth = 2);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.745),
      6,
      Paint()..color = primary.withAlpha(dark ? 170 : 120),
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.735),
      4,
      Paint()..color = primary.withAlpha(dark ? 170 : 120),
    );
    canvas.drawCircle(
      Offset(size.width * 0.87, size.height * 0.765),
      4,
      Paint()..color = primary.withAlpha(dark ? 170 : 120),
    );
  }

  void _drawGear(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final start = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * (radius + 8),
        center.dy + math.sin(angle) * (radius + 8),
      );
      canvas.drawLine(start, end, paint);
    }
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.42, paint);
  }

  @override
  bool shouldRepaint(covariant _RoboticsBlueprintPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}
