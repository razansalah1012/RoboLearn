import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/learning_module_model.dart';
import '../../services/course_service.dart';
import '../../theme/app_colors.dart';
import 'course_editor_screen.dart';

class AdminCourseListScreen extends StatefulWidget {
  const AdminCourseListScreen({super.key});

  @override
  State<AdminCourseListScreen> createState() => _AdminCourseListScreenState();
}

class _AdminCourseListScreenState extends State<AdminCourseListScreen> {
  final CourseService _courseService = CourseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text('Course Architect', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cranberry,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CourseEditorScreen()),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: _courseService.getAllCoursesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.architecture, size: 64, color: AppColors.taupe),
                  const SizedBox(height: 16),
                  Text("No courses architected yet.", style: GoogleFonts.exo2()),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CourseEditorScreen()),
                    ),
                    child: const Text("Create First Course"),
                  )
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.cranberry,
                    child: Icon(Icons.book, color: Colors.white),
                  ),
                  title: Text(course.title, style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text("${course.category} • ${course.difficulty.name.toUpperCase()}"),
                  trailing: const Icon(Icons.edit_note, color: AppColors.plum),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CourseEditorScreen(course: course)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
