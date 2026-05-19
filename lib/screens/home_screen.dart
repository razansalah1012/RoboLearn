import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/tech_background_animation.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'learning/course_selection_screen.dart';
import 'workshop_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heroController;
  late Animation<double> _heroFade;
  late Animation<double> _heroSlide;

  int _selectedNavIndex = 0; 

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );
    _heroSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );
    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onNavTap(int i) {
    setState(() => _selectedNavIndex = i);
  }

  Widget _buildBody() {
    switch (_selectedNavIndex) {
      case 1:
        return const CourseSelectionScreen();
      case 2:
        return const LeaderboardScreen();
      case 3:
        return const WorkshopScreen();
      case 4:
        return const ProfileScreen();
      default:
        return Stack(
          children: [
            const Positioned.fill(child: TechBackgroundAnimation()),
            Column(
              children: [
                const _HomeHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: AnimatedBuilder(
                      animation: _heroController,
                      builder: (context, child) => Opacity(
                        opacity: _heroFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _heroSlide.value),
                          child: child,
                        ),
                      ),
                      child: const _HeroSection(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cranberry, AppColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.exo2(
                      fontSize: 13,
                      color: AppColors.ivory.withAlpha(200),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  FutureBuilder(
                    future: AuthService().getUserData(AuthService().currentUser?.uid ?? ""),
                    builder: (context, snapshot) {
                      String displayName = "RoboLearner";
                      if (snapshot.hasData && snapshot.data != null) {
                        displayName = snapshot.data!.name;
                      }
                      return Text(
                        displayName,
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ivory,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.ivory.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: AppColors.ivory, size: 22),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.ivory),
                    onPressed: () async {
                      await AuthService().logout();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.precision_manufacturing_rounded, color: AppColors.cranberry, size: 38),
              const SizedBox(width: 16),
              Text(
                'RoboLearn',
                style: GoogleFonts.orbitron(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cranberry,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Al Jazari Innovation Hub',
            style: GoogleFonts.exo2(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.plum),
          ),
          const SizedBox(height: 24),
          const Text(
            'Architecting the future of robotics education through structured, gamified learning paths.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.taupe),
          ),
          const SizedBox(height: 40),
          _QuickStartSection(),
        ],
      ),
    );
  }
}

class _QuickStartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getUserData(AuthService().currentUser?.uid ?? ""),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final user = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "NEXT STEPS",
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.plum, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            if (user.role == 'admin') ...[
              _QuickActionTile(icon: Icons.how_to_reg, label: "Review Pending Approvals", color: Colors.orange),
              _QuickActionTile(icon: Icons.add_chart, label: "Monitor Hub Analytics", color: Colors.blue),
            ] else if (user.role == 'committee') ...[
              _QuickActionTile(icon: Icons.add_box_outlined, label: "Create New Course Module", color: AppColors.cranberry),
              _QuickActionTile(icon: Icons.event_available, label: "Manage Hub Workshops", color: AppColors.plum),
            ] else ...[
              _QuickActionTile(icon: Icons.rocket_launch, label: "Resume Learning Path", color: AppColors.cranberry),
              _QuickActionTile(icon: Icons.calendar_today, label: "Browse Upcoming Workshops", color: AppColors.plum),
            ],
          ],
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickActionTile({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: GoogleFonts.exo2(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}
