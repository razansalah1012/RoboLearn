import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/learning_module_model.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import 'module_editor_screen.dart';

class CourseEditorScreen extends StatefulWidget {
  final Course? course;
  const CourseEditorScreen({super.key, this.course});

  @override
  State<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends State<CourseEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = FirebaseFirestore.instance;
  final _auth = AuthService();
  final _courseService = CourseService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _category;
  late Difficulty _difficulty;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descriptionController = TextEditingController(text: widget.course?.description ?? '');
    _category = widget.course?.category ?? 'Programming';
    _difficulty = widget.course?.difficulty ?? Difficulty.beginner;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final baseData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _category,
        'difficulty': _difficulty.name,
        'createdBy': user.uid,
        'thumbnailUrl': '', // Placeholder for now
      };

      if (widget.course == null) {
        // New course: set createdAt and default isPublished=false
        final courseData = {
          ...baseData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isPublished': false,
        };
        await _db.collection('courses').add(courseData);
      } else {
        // Update existing: only update mutable fields and updatedAt
        final updateData = {
          ...baseData,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await _db.collection('courses').doc(widget.course!.id).update(updateData);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving course: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addModule() {
    if (widget.course == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the course architecture first!')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleEditorScreen(
          courseId: widget.course!.id,
          nextOrder: 0, 
        ),
      ),
    );
  }

  void _editModule(LearningModule module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleEditorScreen(
          courseId: widget.course!.id,
          module: module,
          nextOrder: module.order,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(widget.course == null ? 'New Course' : 'Edit Course', 
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cranberry,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Course Details", style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.cranberry)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Course Title', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: ['Programming', 'Robotics', 'Drones', 'Mechanics', 'Engineering']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Difficulty>(
                value: _difficulty,
                decoration: const InputDecoration(labelText: 'Proficiency Level', border: OutlineInputBorder()),
                items: Difficulty.values
                    .map((diff) => DropdownMenuItem(value: diff, child: Text(diff.name.toUpperCase())))
                    .toList(),
                onChanged: (val) => setState(() => _difficulty = val!),
              ),
              const SizedBox(height: 30),
              if (widget.course != null) ...[
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text("Modules", style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.cranberry)),
                     ElevatedButton.icon(
                       onPressed: _addModule,
                       icon: const Icon(Icons.add),
                       label: const Text("Add Module"),
                     )
                   ],
                 ),
                 const SizedBox(height: 10),
                 _ModuleList(
                   courseId: widget.course!.id,
                   onEdit: _editModule,
                   courseService: _courseService,
                 ),
                 const SizedBox(height: 30),
              ],
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCourse,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.cranberry),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Save Course Architecture", style: GoogleFonts.exo2(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleList extends StatelessWidget {
  final String courseId;
  final Function(LearningModule) onEdit;
  final CourseService courseService;
  
  const _ModuleList({
    required this.courseId, 
    required this.onEdit,
    required this.courseService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LearningModule>>(
      stream: courseService.getModulesStream(courseId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData) return const LinearProgressIndicator();
        
        final modules = snapshot.data!;
        if (modules.isEmpty) return const Text("No modules added yet.");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            return Card(
              child: ListTile(
                title: Text(module.title),
                subtitle: Text("${module.lessons.length} Lessons"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(module),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
