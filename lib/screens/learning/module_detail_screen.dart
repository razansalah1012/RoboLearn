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
    final _courseService = CourseService();

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(module.title, style: GoogleFonts.orbitron(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cranberry,
      ),
      body: SingleChildScrollView(
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
              "Curriculum",
              style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.cranberry),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: module.lessons.length,
              itemBuilder: (context, index) {
                final lesson = module.lessons[index];
                final isUnlocked = _courseService.isLessonUnlocked(lesson, module, progress);
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
              isUnlocked: module.lessons.every((l) => progress?.completedLessonIds.contains(l.id) ?? false),
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
        side: BorderSide(color: isUnlocked ? AppColors.cranberry.withOpacity(0.2) : Colors.grey.shade300),
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
                  "Final Assessment",
                  style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Prove your mastery of ${module.title}",
                  style: GoogleFonts.exo2(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isUnlocked ? onTap : null,
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }
}
