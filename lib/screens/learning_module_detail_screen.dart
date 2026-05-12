import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/learning_module_model.dart';

class LearningModuleDetailScreen extends StatelessWidget {
  final LearningModule module;

  const LearningModuleDetailScreen({super.key, required this.module});

  Color get _difficultyColor {
    switch (module.difficulty) {
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
                  gradient: LinearGradient(
                    colors: [AppColors.cranberry, AppColors.plum],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // decorative circles
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
                    Positioned(
                      left: -20,
                      bottom: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.ivory.withAlpha(8),
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
                                _Badge(label: module.category, color: AppColors.ivory.withAlpha(40)),
                                const SizedBox(width: 8),
                                _Badge(label: module.difficulty, color: _difficultyColor.withAlpha(180)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              module.title,
                              style: GoogleFonts.orbitron(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ivory,
                                height: 1.3,
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
                  // Description box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.ivory,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                          color: AppColors.plum.withAlpha(25), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cranberry.withAlpha(10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.cranberry.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.info_outline_rounded,
                              color: AppColors.cranberry, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            module.description,
                            style: GoogleFonts.exo2(
                              fontSize: 14,
                              color: AppColors.taupe,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Module Content',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cranberry,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Container(
                    height: 3,
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.ivory,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                          color: AppColors.plum.withAlpha(20), width: 1),
                    ),
                    child: Text(
                      module.content.isEmpty
                          ? 'No content available for this module yet.'
                          : module.content,
                      style: GoogleFonts.exo2(
                        fontSize: 14,
                        color: AppColors.cranberry,
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Meta footer
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 14, color: AppColors.taupe.withAlpha(180)),
                      const SizedBox(width: 6),
                      Text(
                        'Published ${_formatDate(module.createdAt)}',
                        style: GoogleFonts.exo2(
                            fontSize: 12, color: AppColors.taupe),
                      ),
                    ],
                  ),
                  
                  if (module.quiz.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _QuizSection(module: module),
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

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _QuizSection extends StatefulWidget {
  final LearningModule module;
  const _QuizSection({required this.module});

  @override
  State<_QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<_QuizSection> {
  int? _selectedAnswer;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    
    if (_selectedAnswer == widget.module.quiz[_currentQuestionIndex].correctIndex) {
      _score++;
    }

    if (_currentQuestionIndex < widget.module.quiz.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF4A7C59).withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4A7C59).withAlpha(40)),
        ),
        child: Column(
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFF4A7C59), size: 48),
            const SizedBox(height: 16),
            Text(
              'Quiz Completed!',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A7C59),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You scored $_score out of ${widget.module.quiz.length}',
              style: GoogleFonts.exo2(fontSize: 15, color: AppColors.taupe),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => setState(() {
                _quizCompleted = false;
                _currentQuestionIndex = 0;
                _score = 0;
                _selectedAnswer = null;
              }),
              child: const Text('Retry Quiz'),
            ),
          ],
        ),
      );
    }

    final q = widget.module.quiz[_currentQuestionIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.plum.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.plum.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.plum, size: 24),
              const SizedBox(width: 12),
              Text(
                'Knowledge Check',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.plum,
                ),
              ),
              const Spacer(),
              Text(
                'Q${_currentQuestionIndex + 1}/${widget.module.quiz.length}',
                style: GoogleFonts.exo2(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.taupe),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            q.question,
            style: GoogleFonts.exo2(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.cranberry,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(q.options.length, (i) {
            final isSelected = _selectedAnswer == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedAnswer = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.plum : AppColors.ivory,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.plum : AppColors.plum.withAlpha(40),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.ivory : AppColors.taupe,
                          width: 2,
                        ),
                        color: isSelected ? AppColors.ivory : Colors.transparent,
                      ),
                      child: isSelected ? const Icon(Icons.check, size: 12, color: AppColors.plum) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q.options[i],
                        style: GoogleFonts.exo2(
                          fontSize: 13,
                          color: isSelected ? AppColors.ivory : AppColors.cranberry,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cranberry,
                foregroundColor: AppColors.ivory,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _selectedAnswer == null ? null : _submitAnswer,
              child: Text(
                _currentQuestionIndex == widget.module.quiz.length - 1 ? 'Finish Quiz' : 'Next Question',
                style: GoogleFonts.exo2(fontWeight: FontWeight.w700),
              ),
            ),
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.exo2(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.ivory,
        ),
      ),
    );
  }
}
