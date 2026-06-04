import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/animated_interactive_card.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/dashboard_service.dart';
import '../models/user_model.dart';
import '../models/learning_module_model.dart';
import 'login_screen.dart';
import 'admin/course_editor_screen.dart';
import 'committee/committee_profile_screen.dart';
import 'committee/committee_directory_screen.dart';
import 'committee/sponsorship_management_screen.dart';
import 'committee/workshop_management_screen.dart';
import 'committee/attendance_tracker_screen.dart';
import 'committee/notification_announcement_screen.dart';
import 'create_announcement_screen.dart'; 
import 'announcements_screen.dart';        
import '../widgets/placeholder_screen.dart';

class CommitteeDashboard extends StatefulWidget {
  const CommitteeDashboard({super.key});

  @override
  State<CommitteeDashboard> createState() => _CommitteeDashboardState();
}

class _CommitteeDashboardState extends State<CommitteeDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CourseService _courseService = CourseService();
  final DashboardService _dashboardService = DashboardService();
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(opacity: 0.4, child: TechBackgroundAnimation()),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildDynamicHeader(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(dashboardService: _dashboardService),
                      _CoursesTab(courseService: _courseService),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index != 1) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: AppColors.cranberry,
            foregroundColor: AppColors.ivory,
            elevation: 8,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Architect Course',
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CourseEditorScreen(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDynamicHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 100);
        final userData = UserModel.fromMap(
          snapshot.data!.data() as Map<String, dynamic>,
        );

        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 24, 8),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CommitteeProfileScreen(),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: userData.profilePhotoUrl != null
                            ? NetworkImage(userData.profilePhotoUrl!)
                            : null,
                        child: userData.profilePhotoUrl == null
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${userData.name.split(' ').first}!',
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ivory,
                            ),
                          ),
                          Text(
                            userData.roleTitle ?? 'Committee Member',
                            style: GoogleFonts.exo2(
                              fontSize: 10,
                              color: AppColors.ivory.withAlpha(180),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.ivory,
                        size: 20,
                      ),
                      onPressed: () async {
                        await _auth.logout();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.ivory,
                labelColor: AppColors.ivory,
                unselectedLabelColor: AppColors.ivory.withAlpha(140),
                labelStyle: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'ANALYTICS'),
                  Tab(text: 'CURRICULUM'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            child: Center(
              child: Icon(
                Icons.precision_manufacturing,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),

           Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("My Profile"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommitteeProfileScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.contacts_outlined),
            title: const Text("Committee Directory"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CommitteeDirectoryScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on_outlined),
            title: const Text("Sponsorships"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SponsorshipManagementScreen(),
              ),
            ),
          ),
          const Divider(),

           ListTile(
          leading: const Icon(Icons.announcement_outlined, color: AppColors.cranberry),
          title: const Text("Create Announcement", style: TextStyle(fontWeight: FontWeight.w600)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateAnnouncementScreen(),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.view_list_outlined, color: AppColors.cranberry),
          title: const Text("View All Announcements"),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AnnouncementsScreen(),
            ),
          ),
        ),
        const Divider(),

          ListTile(
            leading: const Icon(Icons.event_available_outlined),
            title: const Text("Workshop Management"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WorkshopManagementScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: const Text("Attendance Tracker"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AttendanceTrackerScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: const Text("Equipment"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PlaceholderScreen(
                  title: "Equipment",
                  icon: Icons.build,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none_outlined),
            title: const Text("Notifications"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationAnnouncementScreen(),
              ),
            ),
          ),
              ],
            ),
          ),
           ), 
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => _auth.logout(),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final DashboardService dashboardService;
  const _OverviewTab({required this.dashboardService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: dashboardService.getCommitteeStats(),
      builder: (context, statsSnap) {
        return StreamBuilder<int>(
          stream: dashboardService.getTotalCoursesCount(),
          builder: (context, courseCountSnap) {
            if (statsSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.cranberry),
              );
            }

            final stats = statsSnap.data ?? {'activeStudents': 0, 'totalXpIssued': 0};
            final courseCount = courseCountSnap.data ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatCard(
                    title: 'Active Students',
                    value: stats['activeStudents'].toString(),
                    icon: Icons.people_rounded,
                    color: const Color(0xFF4A7C59),
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'Total Courses',
                    value: courseCount.toString(),
                    icon: Icons.architecture_rounded,
                    color: AppColors.plum,
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'Workshop Management',
                    value: 'MANAGE',
                    icon: Icons.handyman_rounded,
                    color: AppColors.cranberry,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkshopManagementScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'Announcements',
                    value: 'POST',
                    icon: Icons.announcement_rounded,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAnnouncementScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'Attendance Tracker',
                    value: 'CHECK IN',
                    icon: Icons.fact_check_outlined,
                    color: const Color(0xFF4A7C59),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttendanceTrackerScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'XP Issued',
                    value: '${(stats['totalXpIssued'] / 1000).toStringAsFixed(1)}k',
                    icon: Icons.bolt_rounded,
                    color: Colors.orange,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CoursesTab extends StatelessWidget {
  final CourseService courseService;
  const _CoursesTab({required this.courseService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: courseService.getAllCoursesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.cranberry),
          );
        }
        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return Center(
            child: Text(
              "No courses architected yet.",
              style: GoogleFonts.exo2(color: AppColors.taupe),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: courses.length,
          itemBuilder: (context, i) => _AdminCourseCard(course: courses[i]),
        );
      },
    );
  }
}

class _AdminCourseCard extends StatelessWidget {
  final Course course;
  const _AdminCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return AnimatedInteractiveCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseEditorScreen(course: course),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.plum.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    course.category.toUpperCase(),
                    style: GoogleFonts.exo2(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.plum,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  course.difficulty.name.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.taupe,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              course.title,
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.cranberry,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              course.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.edit_note,
                      size: 16,
                      color: AppColors.plum,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Tap to edit architecture",
                      style: GoogleFonts.exo2(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.plum,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: course.isPublished,
                  activeThumbColor: Colors.green,
                  activeTrackColor: Colors.green.withValues(alpha: 0.3),
                  onChanged: (val) {
                    CourseService().togglePublishCourse(course.id, val);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cranberry,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, size: 18,color: AppColors.taupe),
        ],
      ),
    );
  }
}
