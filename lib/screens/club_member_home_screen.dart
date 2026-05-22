import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'committee/workshop_management_screen.dart';
import 'committee/sponsorship_management_screen.dart';
import 'learning/course_selection_screen.dart';

class ClubMemberHomeScreen extends StatelessWidget {
  const ClubMemberHomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text("COMMITTEE DASHBOARD", style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MANAGEMENT HUB",
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.plum, letterSpacing: 2),
            ),
            const SizedBox(height: 24),
            _ManagementCard(
              title: "WORKSHOPS",
              subtitle: "Create, edit and manage technical sessions",
              icon: Icons.handyman,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkshopManagementScreen())),
            ),
            const SizedBox(height: 16),
            _ManagementCard(
              title: "SPONSORSHIPS",
              subtitle: "Track club funding and sponsor records",
              icon: Icons.monetization_on,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SponsorshipManagementScreen())),
            ),
            const SizedBox(height: 16),
            _ManagementCard(
              title: "LEARNING MODULES",
              subtitle: "Manage curriculum and courses",
              icon: Icons.school,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseSelectionScreen())),
            ),
            const SizedBox(height: 40),
            Text(
              "QUICK STATS",
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.plum, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            // Placeholder for stats
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatMini(label: "Active Events", value: "3"),
                  _StatMini(label: "Total Members", value: "150"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ManagementCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.plum.withOpacity(0.1))),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cranberry.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: AppColors.cranberry, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.exo2(fontSize: 13, color: AppColors.taupe)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.taupe),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  const _StatMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.plum)),
        Text(label, style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe)),
      ],
    );
  }
}
