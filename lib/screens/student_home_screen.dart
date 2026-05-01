import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/tech_background_animation.dart';
import '../services/auth_service.dart';

import 'login_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
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
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

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

  void _onNavTap(int index) {
    setState(() => _selectedNavIndex = index);
  }

  Widget _getCurrentPage() {
    if (_selectedNavIndex == 1) {
      return const _SimpleStudentPage(
        title: "Learning Materials",
        subtitle: "Access robotics notes, modules, and learning resources.",
        icon: Icons.menu_book_rounded,
      );
    } else if (_selectedNavIndex == 2) {
      return const _SimpleStudentPage(
        title: "Workshops",
        subtitle: "View upcoming workshops and register for club activities.",
        icon: Icons.calendar_month_rounded,
      );
    } else if (_selectedNavIndex == 3) {
      return const _SimpleStudentPage(
        title: "Profile",
        subtitle: "View your account, learning progress, and registrations.",
        icon: Icons.person_rounded,
      );
    }

    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        return Opacity(
          opacity: _heroFade.value,
          child: Transform.translate(
            offset: Offset(0, _heroSlide.value),
            child: child,
          ),
        );
      },
      child: const _HeroSection(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          const Positioned.fill(
            child: TechBackgroundAnimation(),
          ),
          Column(
            children: [
              const _HomeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: _getCurrentPage(),
                ),
              ),
            ],
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
          padding: EdgeInsets.symmetric(
            horizontal: width < 400 ? 16 : 22,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
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
                    Text(
                      'RoboLearner',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orbitron(
                        fontSize: width < 400 ? 18 : 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ivory,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  _HeaderIconButton(
                    icon: Icons.logout,
                    onTap: () => _logout(context),
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

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.ivory.withAlpha(30),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: AppColors.ivory,
          size: 22,
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallPhone = size.width < 380;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 18 : 24,
        vertical: size.height * 0.07,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Image.asset(
                'assets/logo.png',
                height: isSmallPhone ? 58 : 70,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: AppColors.cranberry,
                    size: 38,
                  );
                },
              ),
              Text(
                'RoboLearn',
                style: GoogleFonts.orbitron(
                  fontSize: size.width > 600
                      ? 56
                      : isSmallPhone
                      ? 34
                      : 42,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cranberry,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Al Jazari Innovation Hub',
            style: GoogleFonts.exo2(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.plum,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'A clean, professional platform for robotics education at UTM. '
                  'Learn robotics, join workshops, track your progress, and access club materials.',
              textAlign: TextAlign.center,
              style: GoogleFonts.exo2(
                fontSize: isSmallPhone ? 13 : 15,
                color: AppColors.taupe,
                height: 1.65,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _CTAButton(
                label: 'Start Learning',
                icon: Icons.rocket_launch_rounded,
                filled: true,
                onTap: () {},
              ),
              _CTAButton(
                label: 'View Workshops',
                icon: Icons.calendar_month_rounded,
                filled: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 50),
          const _PlatformFeaturesSection(),
        ],
      ),
    );
  }
}

class _CTAButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _CTAButton({
    required this.label,
    required this.icon,
    required this.filled,
    this.onTap,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_hovered ? 1.04 : 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? AppColors.plum : AppColors.cranberry)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(
              color: widget.filled ? Colors.transparent : AppColors.cranberry,
              width: 2,
            ),
            boxShadow: widget.filled
                ? [
              BoxShadow(
                color: AppColors.cranberry.withAlpha(
                  _hovered ? 70 : 40,
                ),
                blurRadius: _hovered ? 20 : 12,
                offset: const Offset(0, 6),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.filled
                    ? AppColors.ivory
                    : (_hovered ? AppColors.plum : AppColors.cranberry),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.exo2(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: widget.filled
                      ? AppColors.ivory
                      : (_hovered ? AppColors.plum : AppColors.cranberry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformFeaturesSection extends StatelessWidget {
  const _PlatformFeaturesSection();

  static const _features = [
    (
    icon: Icons.menu_book_rounded,
    title: 'Learning Modules',
    desc: 'Structured robotics materials for beginners and advanced learners.',
    color: AppColors.cranberry,
    ),
    (
    icon: Icons.calendar_month_rounded,
    title: 'Workshops',
    desc: 'View and register for robotics workshops and club events.',
    color: AppColors.plum,
    ),
    (
    icon: Icons.build_rounded,
    title: 'Equipment Booking',
    desc: 'Check available lab tools and equipment booking information.',
    color: Color(0xFF4A7C59),
    ),
    (
    icon: Icons.trending_up_rounded,
    title: 'Progress Tracking',
    desc: 'Follow your learning progress and completed robotics activities.',
    color: AppColors.taupe,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final crossAxisCount = width > 900
        ? 4
        : width > 600
        ? 2
        : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: Column(
        children: [
          Text(
            'Student Features',
            style: GoogleFonts.orbitron(
              fontSize: width < 380 ? 22 : 28,
              fontWeight: FontWeight.w700,
              color: AppColors.cranberry,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Everything you need to start your robotics journey',
            style: GoogleFonts.exo2(
              fontSize: 14,
              color: AppColors.taupe,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: width < 380 ? 1.35 : 1.15,
            children: _features
                .map(
                  (feature) => _FeatureCard(
                icon: feature.icon,
                title: feature.title,
                desc: feature.desc,
                iconColor: feature.color,
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color iconColor;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.iconColor,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -6.0 : 0.0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: _hovered
                ? widget.iconColor.withAlpha(80)
                : AppColors.plum.withAlpha(20),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.iconColor.withAlpha(_hovered ? 35 : 12),
              blurRadius: _hovered ? 24 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: widget.iconColor.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.cranberry,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.desc,
              style: GoogleFonts.exo2(
                fontSize: 12,
                color: AppColors.taupe,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleStudentPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SimpleStudentPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width < 400 ? 18 : 24,
        vertical: 70,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.ivory,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.cranberry.withAlpha(25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 52,
                color: AppColors.cranberry,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: width < 400 ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cranberry,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: GoogleFonts.exo2(
                  fontSize: 14,
                  color: AppColors.taupe,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}