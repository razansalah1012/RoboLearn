import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/learning_module_model.dart';
import '../services/course_service.dart';
import '../widgets/tech_background_animation.dart';
import 'learning/course_path_screen.dart';

class LearningModuleScreen extends StatefulWidget {
  const LearningModuleScreen({super.key});

  @override
  State<LearningModuleScreen> createState() => _LearningModuleScreenState();
}

class _LearningModuleScreenState extends State<LearningModuleScreen> {
  final CourseService _courseService = CourseService();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: TechBackgroundAnimation(),
            ),
          ),
          SafeArea(
            child: StreamBuilder<List<Course>>(
              stream: _courseService.getAllCoursesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
                }

                final allCourses = snapshot.data ?? [];
                final categories = ['All', ...allCourses.map((c) => c.category).toSet().toList()];
                
                final displayCourses = _selectedCategory == 'All'
                    ? allCourses
                    : allCourses.where((c) => c.category == _selectedCategory).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildCategoryFilter(categories),
                    Expanded(child: _buildCourseList(displayCourses)),
                  ],
                );
              },
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
        gradient: AppColors.primaryGradient,
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
                child: const Icon(Icons.architecture_rounded,
                    color: AppColors.ivory, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Course Library',
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
            'Master technical disciplines through structured milestones.',
            style: GoogleFonts.exo2(
              fontSize: 12,
              color: AppColors.ivory.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return Container(
      height: 52,
      color: AppColors.ivory.withAlpha(180),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.ivory : AppColors.cranberry,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    if (courses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: courses.length,
      itemBuilder: (context, i) => _CourseCard(course: courses[i]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_mosaic_outlined, size: 56, color: AppColors.taupe),
          const SizedBox(height: 20),
          Text(
            'Architecture Pending',
            style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.cranberry),
          ),
          Text('No courses found in this category.', style: GoogleFonts.exo2(color: AppColors.taupe)),
        ],
      ),
    );
  }
}

class _CourseCard extends StatefulWidget {
  final Course course;
  const _CourseCard({required this.course});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _hovered = false;

  Color get _difficultyColor {
    switch (widget.course.difficulty) {
      case Difficulty.intermediate: return const Color(0xFF4A7C59);
      case Difficulty.advanced: return AppColors.cranberry;
      default: return AppColors.taupe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CoursePathScreen(
            category: widget.course.category,
            difficulty: widget.course.difficulty,
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 16),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.ivory,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.cranberry.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Badge(label: widget.course.category, color: AppColors.plum.withAlpha(20), textColor: AppColors.plum),
                        const SizedBox(width: 8),
                        _Badge(label: widget.course.difficulty.name.toUpperCase(), color: _difficultyColor.withAlpha(20), textColor: _difficultyColor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.course.title,
                      style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.cranberry),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.exo2(fontSize: 13, color: AppColors.taupe),
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
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Badge({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.exo2(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}
