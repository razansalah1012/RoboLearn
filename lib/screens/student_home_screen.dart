import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robolearn/screens/announcements_screen.dart';

import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/brand_logo.dart';
import '../widgets/robotics_blueprint.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import 'learning/course_selection_screen.dart';
import 'student/notification_feed_screen.dart';
import 'workshop_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'feedback_screen.dart';
import 'student_attendance_screen.dart';
import 'student/equipment_booking_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedNavIndex = index);
  }

  Widget _getCurrentPage() {
    switch (_selectedNavIndex) {
      case 0:
        return _HomeTab(
          onStartLearning: () => _onNavTap(1),
          onViewWorkshops: () => _onNavTap(3),
        );
      case 1:
        return const CourseSelectionScreen();
      case 2:
        return const LeaderboardScreen();
      case 3:
        return const AnnouncementsScreen();
      case 4:
        return const WorkshopScreen();
      case 5:
        return const FeedbackScreen();
      case 6:
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
          SafeArea(child: _getCurrentPage()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final VoidCallback onStartLearning;
  final VoidCallback onViewWorkshops;

  const _HomeTab({
    required this.onStartLearning,
    required this.onViewWorkshops,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final NotificationService _notificationService = NotificationService();
  bool _hasUnreadNotifications = false;
  String? _lastSeenNotificationId;
  String? _latestNotificationId;
  StreamSubscription<List<NotificationItem>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = _notificationService
        .getNotificationsStream()
        .listen((notifications) {
          if (notifications.isEmpty) {
            return;
          }

          final latestId = notifications.first.id;
          _latestNotificationId = latestId;

          if (_lastSeenNotificationId == null ||
              _lastSeenNotificationId != latestId) {
            setState(() {
              _hasUnreadNotifications = true;
            });
          }
        });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _openNotificationFeed(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationFeedScreen()),
    );

    if (!mounted) return;
    setState(() {
      _hasUnreadNotifications = false;
      _lastSeenNotificationId = _latestNotificationId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(user?.uid),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildMainHero(context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 34),
                _buildPlatformFeatures(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(String? uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid ?? '')
          .snapshots(),
      builder: (context, snapshot) {
        final userData = snapshot.hasData && snapshot.data!.exists
            ? UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>)
            : null;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
              Expanded(
                child: Row(
                  children: [
                    const BrandLogoMark(size: 34, showHalo: false),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOCKED IN,',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              color: Colors.white70,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userData?.name.split(' ').first.toUpperCase() ??
                                'LEARNER',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.orbitron(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNotificationButton(context),
                  const SizedBox(width: 12),
                  if (userData != null)
                    _UserRankBadge(xp: userData.totalXp, level: userData.level),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openNotificationFeed(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 41),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.ivory,
              size: 24,
            ),
          ),
          if (_hasUnreadNotifications)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.cranberry.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Text(
              "CLUB LAB  |  ROBOTICS PATH",
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.ivory,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const RoboticsBlueprintVisual(height: 126, dark: true),
          const SizedBox(height: 24),
          Text(
            "BUILD ROBOTICS SKILLS",
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Move from microcontrollers and sensors to autonomous robot systems with guided modules and club workshops.",
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              color: Colors.white.withValues(alpha: 0.85),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed: widget.onStartLearning,
                  child: FittedBox(
                    child: Text(
                      "LEARN",
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: widget.onViewWorkshops,
                  child: FittedBox(
                    child: Text(
                      "EVENTS",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
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

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickActionData(
        icon: Icons.menu_book_rounded,
        title: 'Learning',
        subtitle: 'Modules',
        onTap: widget.onStartLearning,
      ),
      _QuickActionData(
        icon: Icons.event_available_rounded,
        title: 'Workshops',
        subtitle: 'Events',
        onTap: widget.onViewWorkshops,
      ),
      _QuickActionData(
        icon: Icons.memory_rounded,
        title: 'Equipment',
        subtitle: 'Book lab kit',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EquipmentBookingScreen()),
        ),
      ),
      _QuickActionData(
        icon: Icons.notifications_active_outlined,
        title: 'Updates',
        subtitle: 'Club news',
        onTap: () => _openNotificationFeed(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: "Quick Access",
          subtitle: "Jump straight into the club tools you use most.",
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) =>
              _QuickActionTile(data: actions[index]),
        ),
      ],
    );
  }

  Widget _buildPlatformFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: "Club Workflow",
          subtitle: "Track participation, equipment, and announcements.",
        ),
        const SizedBox(height: 20),
        _FeatureAction(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentAttendanceScreen(),
              ),
            );
          },
          child: const _FeatureTile(
            icon: Icons.fact_check_outlined,
            title: "Workshop Attendance",
            subtitle: "Check in and track your attendance verification",
          ),
        ),
        const SizedBox(height: 16),
        _FeatureAction(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EquipmentBookingScreen()),
            );
          },
          child: const _FeatureTile(
            icon: Icons.build_outlined,
            title: "Lab Equipment",
            subtitle: "Browse and book lab equipment for your projects",
          ),
        ),
        const SizedBox(height: 16),
        _FeatureAction(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationFeedScreen()),
            );
          },
          child: const _FeatureTile(
            icon: Icons.notifications_active_outlined,
            title: "Club Notifications",
            subtitle:
                "Receive workshop updates and event announcements instantly",
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.plum,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.exo2(
            fontSize: 13,
            color: AppColors.taupe,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickActionData data;

  const _QuickActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ivory,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: data.onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.plum.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: AppColors.cranberry.withValues(alpha: 0.045),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.roseTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(data.icon, color: AppColors.cranberry, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cranberry,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.exo2(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.taupe,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureAction extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _FeatureAction({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: child,
      ),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
              Text(
                "$xp XP",
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.plum,
                ),
              ),
              Text(
                "LVL $level",
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
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
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.plum.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cranberry.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.ivory, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.plum,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.exo2(
                    fontSize: 13,
                    color: AppColors.taupe,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.plum.withValues(alpha: 0.56),
          ),
        ],
      ),
    );
  }
}
