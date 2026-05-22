import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/learning_module_model.dart';
import '../../services/course_service.dart';
import '../../theme/app_colors.dart';
import 'course_path_screen.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  final CourseService _courseService = CourseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<Course>>(
              stream: _courseService.getAllCoursesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allCourses = snapshot.data ?? [];
                
                // Filter only published courses for students
                final publishedCourses = allCourses.where((c) => c.isPublished).toList();
                
                // Extract unique categories from published courses
                final categories = publishedCourses.map((c) => c.category).toSet().toList();

                if (categories.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final catName = categories[index];
                    return _CategoryCard(
                      name: catName,
                      icon: _getIconForCategory(catName),
                      color: AppColors.plum,
                      onTap: () => _showProficiencyDialog(context, catName),
                    );
                  },
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        color: AppColors.cranberry,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT DISCIPLINE',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Choose your technical focus to begin your path.",
            style: GoogleFonts.exo2(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.architecture_rounded, size: 64, color: AppColors.taupe),
          const SizedBox(height: 16),
          Text(
            "No Active Disciplines",
            style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: AppColors.cranberry),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text(
              "Our architects haven't published any courses yet. Check back soon!",
              textAlign: TextAlign.center,
              style: GoogleFonts.exo2(color: AppColors.taupe),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'programming': return Icons.code;
      case 'robotics': return Icons.precision_manufacturing;
      case 'drones': return Icons.flight;
      default: return Icons.category;
    }
  }

  void _showProficiencyDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.ivory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Select Mastery Level", 
          style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.cranberry)),
        content: Text("Determine your starting point for $category. Choose the path that matches your current expertise.",
          style: GoogleFonts.exo2(color: AppColors.taupe, height: 1.5)),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          Column(
            children: [
              _ProficiencyButton(
                label: "BEGINNER",
                color: AppColors.plum,
                onPressed: () => _navigateToCourse(context, category, Difficulty.beginner),
              ),
              const SizedBox(height: 12),
              _ProficiencyButton(
                label: "INTERMEDIATE",
                color: AppColors.plum,
                onPressed: () => _navigateToCourse(context, category, Difficulty.intermediate),
              ),
              const SizedBox(height: 12),
              _ProficiencyButton(
                label: "ADVANCED",
                color: AppColors.cranberry,
                onPressed: () => _navigateToCourse(context, category, Difficulty.advanced),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToCourse(BuildContext context, String category, Difficulty difficulty) {
    Navigator.pop(context); 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoursePathScreen(
          category: category,
          difficulty: difficulty,
        ),
      ),
    );
  }
}

class _ProficiencyButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ProficiencyButton({required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label, style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              name.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
