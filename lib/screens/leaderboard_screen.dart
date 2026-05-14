import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LeaderboardList(filterByXP: true), // All Time
                _LeaderboardList(filterByXP: false), // Top Graduates
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard_rounded, color: AppColors.cranberry, size: 28),
              const SizedBox(width: 12),
              Text(
                "Hall of Fame",
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cranberry,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Recognizing the Hub's most dedicated architects.",
            style: GoogleFonts.exo2(color: AppColors.taupe, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.plum.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.cranberry,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.taupe,
        labelStyle: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: "ALL TIME XP"),
          Tab(text: "GRADUATES"),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final bool filterByXP;
  const _LeaderboardList({required this.filterByXP});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('users')
        .orderBy(filterByXP ? 'totalXp' : 'completedCoursesCount', descending: true)
        .limit(30);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
        }

        final users = snapshot.data?.docs ?? [];
        if (users.isEmpty) {
          return Center(
            child: Text("No ranking data yet.", style: GoogleFonts.exo2(color: AppColors.taupe)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = UserModel.fromMap(users[index].data() as Map<String, dynamic>);
            return _RankTile(user: user, rank: index + 1, showXP: filterByXP);
          },
        );
      },
    );
  }
}

class _RankTile extends StatelessWidget {
  final UserModel user;
  final int rank;
  final bool showXP;

  const _RankTile({required this.user, required this.rank, required this.showXP});

  @override
  Widget build(BuildContext context) {
    bool isTopThree = rank <= 3;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isTopThree 
          ? Border.all(color: _getRankColor().withOpacity(0.5), width: 2)
          : Border.all(color: AppColors.plum.withOpacity(0.05)),
        boxShadow: isTopThree ? [
          BoxShadow(color: _getRankColor().withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
        ] : [],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isTopThree ? _getRankColor() : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            "$rank",
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isTopThree ? Colors.white : AppColors.taupe,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: GoogleFonts.exo2(fontWeight: FontWeight.bold, color: AppColors.cranberry),
        ),
        subtitle: Text(
          "Level ${user.level} Architect",
          style: GoogleFonts.exo2(fontSize: 11, color: AppColors.taupe),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              showXP ? "${user.totalXp} XP" : "${user.completedCoursesCount} Courses",
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isTopThree ? _getRankColor() : AppColors.plum,
              ),
            ),
            if (isTopThree)
              Icon(Icons.stars_rounded, size: 14, color: _getRankColor()),
          ],
        ),
      ),
    );
  }

  Color _getRankColor() {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return AppColors.taupe;
  }
}
