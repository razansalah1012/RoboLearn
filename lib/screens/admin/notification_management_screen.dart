import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class NotificationManagementScreen extends StatelessWidget {
  const NotificationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text("Notifications", style: GoogleFonts.orbitron(fontSize: 16)),
        backgroundColor: AppColors.cranberry,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active_outlined, size: 64, color: AppColors.taupe),
            const SizedBox(height: 16),
            Text("Communication Hub", style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Push notification deployment is being configured."),
          ],
        ),
      ),
    );
  }
}
