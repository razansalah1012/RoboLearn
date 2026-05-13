import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/tech_background_animation.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'learning_module_screen.dart';
import 'profile_screen.dart';

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

  int _selectedNavIndex = 0; // 0=Home, 1=Learn, 2=Workshops, 3=Profile

  final _featuresKey = GlobalKey();
  final _aboutKey = GlobalKey();
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

  // ── NAVIGATION ITEMS ─────────────────────────────────────────────────────

  void _onNavTap(int i) {
    setState(() => _selectedNavIndex = i);
  }

  Widget _buildBody() {
    switch (_selectedNavIndex) {
      case 1:
        return const LearningModuleScreen();
      case 3:
        return const ProfileScreen();
      default:
        return Stack(
          children: [
            const Positioned.fill(child: TechBackgroundAnimation()),
            Column(
              children: [
                const _HomeHeader(),
                Expanded(
                  child: Center(
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
                        child: _HeroSection(
                          onExplore: null,
                          onDemo: () {},
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// HOME HEADER
// ─────────────────────────────────────────────────────────────────────────────
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
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.ivory.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: AppColors.ivory, size: 22),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.ivory),
                    tooltip: "Logout",
                    onPressed: () async {
                      await AuthService().signOut();
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

// ─────────────────────────────────────────────────────────────────────────────
// TOP NAV BAR
// ─────────────────────────────────────────────────────────────────────────────
class _TopNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onNavTap;

  const _TopNavBar({required this.activeIndex, required this.onNavTap});

  static const _labels = ['Home', 'Features', 'Dashboard', 'About', 'Contact'];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;

    return Container(
      color: AppColors.cranberry,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              // Logo + Brand
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.ivory.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing_rounded,
                      color: AppColors.ivory,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RoboLearn',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ivory,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Nav links (hide on mobile)
              if (!isMobile)
                Row(
                  children: List.generate(_labels.length, (i) {
                    final isActive = i == activeIndex;
                    return GestureDetector(
                      onTap: () => onNavTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.ivory : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusPill),
                          border: isActive
                              ? null
                              : Border.all(
                                  color: Colors.transparent, width: 1),
                        ),
                        child: Text(
                          _labels[i],
                          style: GoogleFonts.exo2(
                            fontSize: 14,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? AppColors.cranberry
                                : AppColors.ivory.withAlpha(210),
                          ),
                        ),
                      ),
                    );
                  }),
                )
              else
                // Mobile hamburger
                Icon(Icons.menu_rounded, color: AppColors.ivory, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final VoidCallback? onExplore;
  final VoidCallback? onDemo;

  const _HeroSection({this.onExplore, this.onDemo});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: size.height * 0.08,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Logo and App Name ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 70,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: AppColors.cranberry,
                    size: 38,
                  );
                },
              ),
              const SizedBox(width: 16),
              Text(
                'RoboLearn',
                style: GoogleFonts.orbitron(
                  fontSize: size.width > 600 ? 56 : 42,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cranberry,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Subtitle ──────────────────────────────────────────────
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

          // ── Description ──────────────────────────────────────────
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'A clean, professional platform for robotics education at UTM. '
              'Streamlined learning, efficient event management, and seamless equipment tracking.',
              textAlign: TextAlign.center,
              style: GoogleFonts.exo2(
                fontSize: 15,
                color: AppColors.taupe,
                height: 1.65,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // ── CTA Buttons ──────────────────────────────────────────
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              // Filled – Explore Platform
              _CTAButton(
                label: 'Explore Platform',
                icon: Icons.rocket_launch_rounded,
                filled: true,
                onTap: onExplore,
              ),
              // Outlined – View Demo
              _CTAButton(
                label: 'View Demo',
                icon: Icons.play_arrow_rounded,
                filled: false,
                onTap: onDemo,
              ),
            ],
          ),
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
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_hovered ? 1.04 : 1.0),
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
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
                      color: AppColors.cranberry.withAlpha(_hovered ? 70 : 40),
                      blurRadius: _hovered ? 20 : 12,
                      offset: const Offset(0, 6),
                    )
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

// ─────────────────────────────────────────────────────────────────────────────
// PLATFORM FEATURES SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _PlatformFeaturesSection extends StatelessWidget {
  const _PlatformFeaturesSection({super.key});

  static const _features = [
    (
      icon: Icons.menu_book_rounded,
      title: 'Learning Modules',
      desc:
          'Structured robotics curriculum designed for every skill level, from beginner to advanced.',
      color: AppColors.cranberry,
    ),
    (
      icon: Icons.calendar_month_rounded,
      title: 'Workshop Management',
      desc:
          'Register, track, and manage robotics workshops and events with real-time updates.',
      color: AppColors.plum,
    ),
    (
      icon: Icons.build_rounded,
      title: 'Equipment Booking',
      desc:
          'Reserve lab equipment and track usage across sessions with an intuitive interface.',
      color: Color(0xFF4A7C59),
    ),
    (
      icon: Icons.trending_up_rounded,
      title: 'Progress Tracking',
      desc:
          'Visualise your learning journey with detailed progress analytics and milestones.',
      color: AppColors.taupe,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 800 ? 4 : (width > 500 ? 2 : 1);

    return Container(
      color: const Color(0xFFF5E8D5), // slightly darker beige stripe
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          Text(
            'Platform Features',
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everything you need to excel in robotics education',
            style: GoogleFonts.exo2(
              fontSize: 14,
              color: AppColors.taupe,
            ),
          ),
          const SizedBox(height: 40),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: _features
                .map((f) => _FeatureCard(
                      icon: f.icon,
                      title: f.title,
                      desc: f.desc,
                      iconColor: f.color,
                    ))
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
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -6.0 : 0.0),
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
              color: widget.iconColor
                  .withAlpha(_hovered ? 35 : 12),
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
              child: Icon(widget.icon, color: widget.iconColor, size: 26),
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
