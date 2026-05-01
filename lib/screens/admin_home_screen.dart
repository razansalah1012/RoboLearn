import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/animated_interactive_card.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  Future<void> logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: TechBackgroundAnimation(),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AdminHeader(onLogout: logout),

                  const SizedBox(height: 24),

                  // 🟪 Dashboard Title
                  Text(
                    "Dashboard Overview",
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cranberry,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🟪 Stats Section
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxis = constraints.maxWidth > 900
                          ? 4
                          : constraints.maxWidth > 600
                          ? 2
                          : 1;

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxis,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.6,
                        children: const [
                          _StatCard(
                            title: "Users",
                            value: "1,248",
                            icon: Icons.people_alt_rounded,
                            color: AppColors.cranberry,
                          ),
                          _StatCard(
                            title: "Bookings",
                            value: "312",
                            icon: Icons.calendar_month_rounded,
                            color: AppColors.plum,
                          ),
                          _StatCard(
                            title: "Equipment",
                            value: "89",
                            icon: Icons.build_rounded,
                            color: Color(0xFF4A7C59),
                          ),
                          _StatCard(
                            title: "Active Sessions",
                            value: "27",
                            icon: Icons.trending_up_rounded,
                            color: AppColors.taupe,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // 🟪 Quick Actions
                  Text(
                    "Quick Actions",
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cranberry,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: const [
                      _ActionCard(
                        icon: Icons.person_add_alt_1_rounded,
                        title: "Add User",
                      ),
                      _ActionCard(
                        icon: Icons.inventory_2_rounded,
                        title: "Manage Equipment",
                      ),
                      _ActionCard(
                        icon: Icons.event_note_rounded,
                        title: "Create Workshop",
                      ),
                      _ActionCard(
                        icon: Icons.analytics_rounded,
                        title: "View Reports",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔴 HEADER
class _AdminHeader extends StatelessWidget {
  final VoidCallback onLogout;

  const _AdminHeader({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cranberry, AppColors.plum],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Admin Dashboard",
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ivory,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Manage system operations & analytics",
                style: GoogleFonts.exo2(
                  fontSize: 13,
                  color: AppColors.ivory.withAlpha(200),
                ),
              ),
            ],
          ),

          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.ivory,
                size: 30,
              ),
              const SizedBox(width: 12),

              GestureDetector(
                onTap: onLogout,
                child: const Icon(
                  Icons.logout,
                  color: AppColors.ivory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🟪 STAT CARD
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedInteractiveCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.exo2(
              fontSize: 13,
              color: AppColors.taupe,
            ),
          ),
        ],
      ),
    );
  }
}

// 🟪 ACTION CARD
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ActionCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(20),
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: AppColors.plum),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.cranberry,
            ),
          ),
        ],
      ),
    );
  }
}