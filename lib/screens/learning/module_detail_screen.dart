import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/learning_module_model.dart';
import '../../models/user_progress_model.dart';
import '../../services/course_service.dart';
import '../../theme/app_colors.dart';
import 'lesson_view_screen.dart';
import 'quiz_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  final LearningModule module;
  final UserProgress? progress;

  const ModuleDetailScreen({
    super.key,
    required this.module,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final courseService = CourseService();

    return Scaffold(
      backgroundColor: AppColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.description,
                      style: GoogleFonts.exo2(fontSize: 15, color: AppColors.taupe),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "CURRICULUM",
                      style: GoogleFonts.orbitron(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.cranberry,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: module.lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = module.lessons[index];
                        final isUnlocked = courseService.isLessonUnlocked(lesson, module, progress);
                        final isCompleted = progress?.completedLessonIds.contains(lesson.id) ?? false;

                        return _LessonTile(
                          lesson: lesson,
                          index: index,
                          isUnlocked: isUnlocked,
                          isCompleted: isCompleted,
                          onTap: () {
                            if (isUnlocked) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonViewScreen(
                                    module: module,
                                    lessonIndex: index,
                                    progress: progress,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Complete previous lessons to unlock!")),
                              );
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    _QuizActionCard(
                      module: module,
                      isUnlocked: module.lessons.isNotEmpty && 
                        module.lessons.every((l) => progress?.completedLessonIds.contains(l.id) ?? false),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuizScreen(module: module)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
      decoration: const BoxDecoration(
        color: AppColors.cranberry,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              module.title.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LessonTile({
    required this.lesson,
    required this.index,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isUnlocked ? AppColors.cranberry.withAlpha(50) : Colors.grey.shade300),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : (isUnlocked ? AppColors.cranberry : Colors.grey.shade200),
          child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          lesson.title,
          style: GoogleFonts.exo2(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.black87 : Colors.grey,
          ),
        ),
        trailing: Icon(
          isCompleted ? Icons.check_circle : (isUnlocked ? Icons.play_circle_outline : Icons.lock_outline),
          color: isCompleted ? Colors.green : (isUnlocked ? AppColors.cranberry : Colors.grey),
        ),
      ),
    );
  }
}

class _QuizActionCard extends StatelessWidget {
  final LearningModule module;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _QuizActionCard({required this.module, required this.isUnlocked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.plum : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_turned_in, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FINAL ASSESSMENT",
                  style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Prove your mastery of ${module.title}",
                  style: GoogleFonts.exo2(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.plum,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: isUnlocked ? onTap : null,
            child: const Text("START"),
          ),
        ],
      ),
    );
  }
}
