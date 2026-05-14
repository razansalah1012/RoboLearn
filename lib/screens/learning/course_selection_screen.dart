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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Discipline',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cranberry,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Choose your technical focus to begin your path.",
                  style: GoogleFonts.exo2(color: AppColors.taupe),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Course>>(
              stream: _courseService.getAllCoursesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final courses = snapshot.data ?? [];
                // Extract unique categories from actual courses in DB
                final categories = courses.map((c) => c.category).toSet().toList();

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
                      color: _getColorForCategory(catName),
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
              "Club Members have not published any course paths yet.",
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

  Color _getColorForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'programming': return Colors.blue;
      case 'robotics': return Colors.red;
      case 'drones': return Colors.indigo;
      default: return AppColors.plum;
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
        content: Text("Determine your starting point for $category. Beginner covers foundations, Intermediate dives into technical applications.",
          style: GoogleFonts.exo2(color: AppColors.taupe, height: 1.5)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.plum, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _navigateToCourse(context, category, Difficulty.beginner),
                  child: Text("BEGINNER", style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.plum)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.plum,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => _navigateToCourse(context, category, Difficulty.intermediate),
                  child: Text("INTERMEDIATE", style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
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
                color: AppColors.cranberry,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
