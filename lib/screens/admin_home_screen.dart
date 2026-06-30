import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_logo.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/animated_interactive_card.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import 'login_screen.dart';
import 'admin/admin_course_list_screen.dart';
import 'admin/admin_workshop_list_screen.dart';
import 'admin/member_approval_screen.dart';
import 'admin/user_management_screen.dart';
import 'admin/role_management_screen.dart';
import 'admin/notification_management_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final DashboardService _dashboardService = DashboardService();

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
            child: Opacity(opacity: 0.35, child: TechBackgroundAnimation()),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AdminHeader(onLogout: logout),
                  const SizedBox(height: 30),
                  Text(
                    "Architecture Hub",
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cranberry,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDynamicStatsSection(),
                  const SizedBox(height: 32),
                  _buildActivityFeed(),
                  const SizedBox(height: 32),
                  Text(
                    "Deployment Tools",
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.plum,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildToolsGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicStatsSection() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _dashboardService.getAdminStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snapshot.data ?? {};
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
              1.4, // Reduced to 1.4 to provide more height and prevent overflow
          children: [
            _StatCard(
              title: "Students",
              value: stats['students']?.toString() ?? "0",
              icon: Icons.people_outline,
              color: AppColors.cranberry,
            ),
            _StatCard(
              title: "Committee",
              value: stats['committee']?.toString() ?? "0",
              icon: Icons.badge_outlined,
              color: AppColors.plum,
            ),
            _StatCard(
              title: "Pending",
              value: stats['pendingApprovals']?.toString() ?? "0",
              icon: Icons.hourglass_top_rounded,
              color: Colors.orange,
            ),
            StreamBuilder<int>(
              stream: _dashboardService.getTotalCoursesCount(),
              builder: (context, countSnap) => _StatCard(
                title: "Live Courses",
                value: countSnap.data?.toString() ?? "0",
                icon: Icons.architecture,
                color: const Color(0xFF4A7C59),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Activity",
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.plum,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _dashboardService.getRecentActivity(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No recent activity logs.");
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final log = snapshot.data![index];
                return ListTile(
                  leading: const Icon(Icons.history_toggle_off),
                  title: Text(log['action'] ?? ""),
                  subtitle: Text(log['details'] ?? ""),
                  dense: true,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _ActionCard(
          icon: Icons.how_to_reg_rounded,
          title: "Approvals",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MemberApprovalScreen(),
            ),
          ),
        ),
        _ActionCard(
          icon: Icons.manage_accounts_rounded,
          title: "Users",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserManagementScreen(),
            ),
          ),
        ),
        _ActionCard(
          icon: Icons.admin_panel_settings_rounded,
          title: "Roles",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoleManagementScreen(),
            ),
          ),
        ),
        _ActionCard(
          icon: Icons.notifications_active_rounded,
          title: "Notifications",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationManagementScreen(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final VoidCallback onLogout;
  const _AdminHeader({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const BrandLogoMark(size: 42, showHalo: false),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ADMIN PORTAL",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ivory,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "System Architect Access",
                        style: GoogleFonts.exo2(
                          fontSize: 12,
                          color: AppColors.ivory.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.ivory),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cranberry,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.exo2(
                      fontSize: 10,
                      color: AppColors.taupe,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 64) / 2;
    return AnimatedInteractiveCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: SizedBox(
        width: width > 160 ? 160 : width,
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.plum),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.cranberry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
