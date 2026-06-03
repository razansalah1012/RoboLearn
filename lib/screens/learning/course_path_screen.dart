import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/learning_module_model.dart';
import '../../models/user_progress_model.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../learning_module_detail_screen.dart';

class CoursePathScreen extends StatefulWidget {
  final String category;
  final Difficulty difficulty;

  const CoursePathScreen({
    super.key,
    required this.category,
    required this.difficulty,
  });

  @override
  State<CoursePathScreen> createState() => _CoursePathScreenState();
}

class _CoursePathScreenState extends State<CoursePathScreen> {
  final CourseService _courseService = CourseService();
  final AuthService _authService = AuthService();
  
  Course? _course;
  List<LearningModule>? _modules;
  UserProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final courses = await _courseService.getCoursesByCategory(widget.category);
      final course = courses.isNotEmpty 
          ? courses.firstWhere(
              (c) => c.difficulty == widget.difficulty,
              orElse: () => courses.first,
            )
          : null;

      if (course != null) {
        final modules = await _courseService.getModules(course.id);
        
        _courseService.getUserProgress(user.uid, course.id).listen((progress) {
          if (mounted) {
            setState(() {
              _course = course;
              _modules = modules;
              _progress = progress;
              _isLoading = false;
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _modules = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading path: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: SafeArea(
        child: Column(
          children: [
            _buildCompactHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.cranberry))
                  : (_modules == null || _modules!.isEmpty)
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: List.generate(_modules!.length, (index) {
                              final module = _modules![index];
                              final isUnlocked = _courseService.isModuleUnlocked(module, _modules!, _progress);
                              final isCompleted = _progress?.completedModuleIds.contains(module.id) ?? false;
                              final isLast = index == _modules!.length - 1;
                              double indent = (index % 2 == 0) ? 40.0 : -40.0;

                              return _PathNode(
                                module: module,
                                isUnlocked: isUnlocked,
                                isCompleted: isCompleted,
                                isLast: isLast,
                                indent: indent,
                                onTap: () => _onModuleTap(module, isUnlocked),
                              );
                            }),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
      decoration: const BoxDecoration(
        color: AppColors.cranberry,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.category.toUpperCase()} PATH',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  widget.difficulty.name.toUpperCase(),
                  style: GoogleFonts.exo2(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
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
          Text("Architecture Pending", style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.cranberry)),
          Text("Our architects are currently designing this path.", style: GoogleFonts.exo2(color: AppColors.taupe)),
        ],
      ),
    );
  }

  void _onModuleTap(LearningModule module, bool isUnlocked) {
    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Module locked. Complete previous phases first.")));
      return;
    }

    if (_course != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LearningModuleDetailScreen(
            course: _course!,
            module: module,
          ),
        ),
      );
    }
  }
}

class _PathNode extends StatelessWidget {
  final LearningModule module;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isLast;
  final double indent;
  final VoidCallback onTap;

  const _PathNode({
    required this.module,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isLast,
    required this.indent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.translate(
          offset: Offset(indent, 0),
          child: Column(
            children: [
              GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? const Color(0xFF4A7C59) : (isUnlocked ? AppColors.cranberry : Colors.grey.shade300),
                    boxShadow: isUnlocked ? [BoxShadow(color: (isCompleted ? const Color(0xFF4A7C59) : AppColors.cranberry).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))] : [],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted ? Icons.check_rounded : (isUnlocked ? Icons.rocket_launch_rounded : Icons.lock_rounded),
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 140,
                child: Text(
                  module.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w800, color: isUnlocked ? AppColors.cranberry : Colors.grey),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: EdgeInsets.only(left: indent > 0 ? indent : 0, right: indent < 0 ? -indent : 0),
            child: Container(width: 6, height: 80, decoration: BoxDecoration(color: isCompleted ? const Color(0xFF4A7C59).withOpacity(0.4) : Colors.grey.shade200, borderRadius: BorderRadius.circular(3))),
          ),
      ],
    );
  }
}
