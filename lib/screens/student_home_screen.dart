import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/tech_background_animation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'learning/course_selection_screen.dart';
import 'workshop_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedNavIndex = index);
  }

  Widget _getCurrentPage() {
    switch (_selectedNavIndex) {
      case 0:
        return _HomeTab(onStartLearning: () => _onNavTap(1), onViewWorkshops: () => _onNavTap(3));
      case 1:
        return const CourseSelectionScreen();
      case 2:
        return const LeaderboardScreen();
      case 3:
        return const WorkshopScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const Center(child: Text("Error: Tab not found"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          // Animation ONLY shown when on the Home tab (index 0)
          if (_selectedNavIndex == 0)
            const Positioned.fill(
              key: ValueKey('home_bg_anim'),
              child: TechBackgroundAnimation(),
            ),
          SafeArea(
            child: _getCurrentPage(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onStartLearning;
  final VoidCallback onViewWorkshops;

  const _HomeTab({required this.onStartLearning, required this.onViewWorkshops});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(user?.uid),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildMainHero(context),
                const SizedBox(height: 40),
                _buildPlatformFeatures(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(String? uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid ?? '').snapshots(),
      builder: (context, snapshot) {
        final userData = snapshot.hasData && snapshot.data!.exists 
          ? UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>)
          : null;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
          decoration: const BoxDecoration(
            color: AppColors.cranberry,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOCKED IN,',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      color: Colors.white70,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData?.name.split(' ').first.toUpperCase() ?? 'LEARNER',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (userData != null) _UserRankBadge(xp: userData.totalXp, level: userData.level),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.plum,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 56),
          const SizedBox(height: 28),
          Text(
            "ARCHITECT THE FUTURE",
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Start your sequential journey from Arduino foundations to Advanced Robotics. By al jazari club",
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              color: Colors.white.withOpacity(0.85),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.plum,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  onPressed: onStartLearning,
                  child: FittedBox(
                    child: Text("LEARN", style: GoogleFonts.orbitron(fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: onViewWorkshops,
                  child: FittedBox(
                    child: Text(
                      "EVENTS",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(fontWeight: FontWeight.w900, fontSize: 15)
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "CONTINUE FROM WHERE YOU LEFT",
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.plum,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UserRankBadge extends StatelessWidget {
  final int xp;
  final int level;
  const _UserRankBadge({required this.xp, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$xp XP", style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.plum)),
              Text("LVL $level", style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: AppColors.plum, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.plum)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.exo2(fontSize: 13, color: Colors.grey, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
