import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/learning_module_model.dart';
import 'learning/lesson_view_screen.dart';

class LearningModuleDetailScreen extends StatelessWidget {
  final Course course; // Context of the parent discipline
  final LearningModule module;

  const LearningModuleDetailScreen({
    super.key, 
    required this.course, 
    required this.module,
  });

  Color get _difficultyColor {
    // Difficulty is an Enum in our Pro Model
    switch (course.difficulty) {
      case Difficulty.intermediate:
        return const Color(0xFF4A7C59);
      case Difficulty.advanced:
        return AppColors.cranberry;
      default:
        return AppColors.taupe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.cranberry,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.ivory),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Stack(
                  children: [
                    // decorative background elements
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.ivory.withAlpha(12),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                _Badge(label: course.category, color: AppColors.ivory.withAlpha(40)),
                                const SizedBox(width: 8),
                                _Badge(
                                  label: course.difficulty.name.toUpperCase(), 
                                  color: _difficultyColor.withAlpha(180),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              module.title.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ivory,
                                height: 1.3,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content Body ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildObjectiveCard(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Technical Curriculum'),
                  const SizedBox(height: 20),
                  _buildLessonList(context),
                  const SizedBox(height: 32),
                  _buildFooterMeta(),
                  if (module.quiz.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _QuizCTA(module: module),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.plum.withAlpha(25)),
        boxShadow: [BoxShadow(color: AppColors.cranberry.withAlpha(10), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.cranberry, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              module.description,
              style: GoogleFonts.exo2(fontSize: 14, color: AppColors.taupe, height: 1.6, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.cranberry, letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Container(height: 3, width: 40, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildLessonList(BuildContext context) {
    if (module.lessons.isEmpty) {
      return Text("Technical architecture pending. Content arriving soon.", 
        style: GoogleFonts.exo2(color: AppColors.taupe, fontSize: 13));
    }
    return Column(
      children: module.lessons.map((l) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.plum.withAlpha(15))),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.cranberry.withAlpha(10), shape: BoxShape.circle),
            child: Text("${l.order + 1}", style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cranberry)),
          ),
          title: Text(l.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          trailing: const Icon(Icons.play_circle_outline, color: AppColors.plum),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonViewScreen(
                  module: module,
                  lessonIndex: module.lessons.indexOf(l),
                ),
              ),
            );
          },
        ),
      )).toList(),
    );
  }

  Widget _buildFooterMeta() {
    return Row(
      children: [
        Icon(Icons.history_edu_rounded, size: 14, color: AppColors.taupe.withAlpha(180)),
        const SizedBox(width: 6),
        Text(
          'Architected on ${_formatDate(module.createdAt)}',
          style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _QuizCTA extends StatelessWidget {
  final LearningModule module;
  const _QuizCTA({required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.plum,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            'KNOWLEDGE CHECK',
            style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.plum,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {}, 
            child: const Text('START ASSESSMENT'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.exo2(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.ivory, letterSpacing: 0.5)),
    );
  }
}
