import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/learning_module_model.dart';
import '../services/module_service.dart';
import '../widgets/tech_background_animation.dart';
import 'learning_module_detail_screen.dart';

class LearningModuleScreen extends StatefulWidget {
  const LearningModuleScreen({super.key});

  @override
  State<LearningModuleScreen> createState() => _LearningModuleScreenState();
}

class _LearningModuleScreenState extends State<LearningModuleScreen> {
  final ModuleService _service = ModuleService();
  String _selectedCategory = 'All';

  static const _categories = [
    'All', 'Sensors', 'Actuators', 'Programming',
    'Mechanics', 'Electronics', 'AI & Vision', 'General',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: TechBackgroundAnimation(),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildCategoryFilter(),
                Expanded(child: _buildModuleList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cranberry, AppColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.ivory.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: AppColors.ivory, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Learning Modules',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ivory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Structured robotics curriculum for every skill level',
            style: GoogleFonts.exo2(
              fontSize: 12,
              color: AppColors.ivory.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 52,
      color: AppColors.ivory.withAlpha(180),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cranberry : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.cranberry
                      : AppColors.plum.withAlpha(60),
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: GoogleFonts.exo2(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isSelected ? AppColors.ivory : AppColors.cranberry,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModuleList() {
    return StreamBuilder<List<LearningModule>>(
      stream: _service.getModulesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.cranberry),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading modules',
                style: GoogleFonts.exo2(color: AppColors.taupe)),
          );
        }

        final all = snapshot.data ?? [];
        final modules = _selectedCategory == 'All'
            ? all
            : all.where((m) => m.category == _selectedCategory).toList();

        if (modules.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          itemCount: modules.length,
          itemBuilder: (context, i) =>
              _ModuleCard(module: modules[i]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cranberry.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_outlined,
                size: 56, color: AppColors.cranberry),
          ),
          const SizedBox(height: 20),
          Text(
            'No Modules Yet',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon — the committee\nis preparing learning content.',
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 13,
              color: AppColors.taupe,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODULE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ModuleCard extends StatefulWidget {
  final LearningModule module;
  const _ModuleCard({required this.module});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _hovered = false;

  Color get _difficultyColor {
    switch (widget.module.difficulty) {
      case 'Intermediate':
        return const Color(0xFF4A7C59);
      case 'Advanced':
        return AppColors.cranberry;
      default:
        return AppColors.taupe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                LearningModuleDetailScreen(module: widget.module),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 16),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.ivory,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: _hovered
                  ? AppColors.cranberry.withAlpha(60)
                  : AppColors.plum.withAlpha(20),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cranberry.withAlpha(_hovered ? 25 : 10),
                blurRadius: _hovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top gradient accent
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusLarge - 1)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + Difficulty row
                    Row(
                      children: [
                        _Chip(
                          label: widget.module.category,
                          color: AppColors.plum.withAlpha(20),
                          textColor: AppColors.plum,
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          label: widget.module.difficulty,
                          color: _difficultyColor.withAlpha(20),
                          textColor: _difficultyColor,
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: _hovered
                              ? AppColors.cranberry
                              : AppColors.taupe.withAlpha(120),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      widget.module.title,
                      style: GoogleFonts.orbitron(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cranberry,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    Text(
                      widget.module.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.exo2(
                        fontSize: 13,
                        color: AppColors.taupe,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Footer
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 12,
                            color: AppColors.taupe.withAlpha(150)),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(widget.module.createdAt),
                          style: GoogleFonts.exo2(
                            fontSize: 11,
                            color: AppColors.taupe.withAlpha(180),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Read more →',
                          style: GoogleFonts.exo2(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _hovered
                                ? AppColors.cranberry
                                : AppColors.plum,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Chip(
      {required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.exo2(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
