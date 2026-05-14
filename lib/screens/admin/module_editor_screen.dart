import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/learning_module_model.dart';
import '../../theme/app_colors.dart';
import '../../services/course_service.dart';
import '../../services/gemini_service.dart';

class ModuleEditorScreen extends StatefulWidget {
  final String courseId;
  final LearningModule? module;
  final int nextOrder;

  const ModuleEditorScreen({
    super.key,
    required this.courseId,
    this.module,
    required this.nextOrder,
  });

  @override
  State<ModuleEditorScreen> createState() => _ModuleEditorScreenState();
}

class _ModuleEditorScreenState extends State<ModuleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final CourseService _courseService = CourseService();
  final GeminiService _gemini = GeminiService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<Lesson> _lessons;
  late List<QuizQuestion> _quizQuestions;
  
  bool _isSaving = false;
  bool _isAiProcessing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.module?.title ?? '');
    _descriptionController = TextEditingController(text: widget.module?.description ?? '');
    _lessons = List.from(widget.module?.lessons ?? []);
    _quizQuestions = List.from(widget.module?.quiz ?? []);
    _lessons.sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _runAiResearch() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a module title for AI context.")));
      return;
    }
    setState(() => _isAiProcessing = true);
    try {
      final result = await _gemini.researchCategory(_titleController.text);
      final newLesson = Lesson(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result['title'] ?? 'AI Technical Analysis',
        content: result['content'] ?? '',
        order: _lessons.length,
        createdAt: DateTime.now(),
      );
      setState(() => _lessons.add(newLesson));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AI Error: $e")));
    } finally {
      setState(() => _isAiProcessing = false);
    }
  }

  Future<void> _runAiQuiz() async {
    if (_lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Architect lessons first for AI quiz context.")));
      return;
    }
    setState(() => _isAiProcessing = true);
    try {
      final content = _lessons.map((l) => l.content).join("\n");
      final questions = await _gemini.generateQuiz(content);
      setState(() => _quizQuestions.addAll(questions));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AI Error: $e")));
    } finally {
      setState(() => _isAiProcessing = false);
    }
  }

  Future<void> _saveModule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Module requires at least one lesson.")));
      return;
    }

    setState(() => _isSaving = true);

    final List<Lesson> synchronizedLessons = [];
    for (int i = 0; i < _lessons.length; i++) {
      final l = _lessons[i];
      synchronizedLessons.add(Lesson(
        id: l.id,
        title: l.title,
        content: l.content,
        videoUrl: l.videoUrl,
        codeSnippet: l.codeSnippet,
        order: i,
        createdAt: l.createdAt,
      ));
    }

    final updatedModule = LearningModule(
      id: widget.module?.id ?? '',
      courseId: widget.courseId,
      title: _titleController.text,
      description: _descriptionController.text,
      order: widget.module?.order ?? widget.nextOrder,
      xpValue: synchronizedLessons.length * 20,
      lessons: synchronizedLessons,
      quiz: _quizQuestions,
      createdAt: widget.module?.createdAt ?? DateTime.now(),
    );

    try {
      await _courseService.saveModule(updatedModule);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deployment Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(widget.module == null ? 'Draft Milestone' : 'Edit Milestone', style: GoogleFonts.orbitron(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cranberry,
        actions: [
          _AiToolMenu(onResearch: _runAiResearch, onQuiz: _runAiQuiz, loading: _isAiProcessing),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Milestone Title', prefixIcon: Icon(Icons.architecture)),
                validator: (val) => val!.isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Technical Objectives', prefixIcon: Icon(Icons.notes)),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader("Technical Lessons", () => _showLessonDialog()),
              _buildLessonList(),
              const SizedBox(height: 32),
              _buildSectionHeader("Knowledge Validation", () => _showQuizDialog()),
              _buildQuizList(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveModule,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.cranberry),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("COMMIT TO ARCHITECTURE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.plum)),
        IconButton(icon: const Icon(Icons.add_circle, color: AppColors.plum), onPressed: onAdd),
      ],
    );
  }

  Widget _buildLessonList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _lessons.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _lessons.removeAt(oldIndex);
          _lessons.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        return Card(
          key: ValueKey(lesson.id),
          child: ListTile(
            leading: const Icon(Icons.drag_handle),
            title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => setState(() => _lessons.removeAt(index))),
            onTap: () => _showLessonDialog(lesson: lesson, index: index),
          ),
        );
      },
    );
  }

  Widget _buildQuizList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _quizQuestions.length,
      itemBuilder: (context, index) {
        final q = _quizQuestions[index];
        return Card(
          child: ListTile(
            title: Text(q.question, style: const TextStyle(fontSize: 13)),
            trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => setState(() => _quizQuestions.removeAt(index))),
            onTap: () => _showQuizDialog(question: q, index: index),
          ),
        );
      },
    );
  }

  void _showLessonDialog({Lesson? lesson, int? index}) {
    final titleC = TextEditingController(text: lesson?.title ?? '');
    final contentC = TextEditingController(text: lesson?.content ?? '');
    final snippetC = TextEditingController(text: lesson?.codeSnippet ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lesson == null ? "Add Lesson" : "Edit Lesson"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: "Lesson Title")),
              TextField(controller: contentC, decoration: const InputDecoration(labelText: "Technical Content (Markdown)"), maxLines: 4),
              TextField(controller: snippetC, decoration: const InputDecoration(labelText: "Code Snippet (Optional)"), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              final newL = Lesson(
                id: lesson?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleC.text,
                content: contentC.text,
                codeSnippet: snippetC.text.isEmpty ? null : snippetC.text,
                order: index ?? _lessons.length,
                createdAt: lesson?.createdAt ?? DateTime.now(),
              );
              setState(() {
                if (index != null) _lessons[index] = newL;
                else _lessons.add(newL);
              });
              Navigator.pop(context);
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  void _showQuizDialog({QuizQuestion? question, int? index}) {
    final qC = TextEditingController(text: question?.question ?? '');
    final List<TextEditingController> oCs = List.generate(4, (i) => TextEditingController(text: (question?.options.length ?? 0) > i ? question!.options[i] : ''));
    int correctIdx = question?.correctIndex ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(question == null ? "Add Assessment" : "Edit Question"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: qC, decoration: const InputDecoration(labelText: "Question")),
                const SizedBox(height: 10),
                ...List.generate(4, (i) => Row(
                  children: [
                    Radio<int>(value: i, groupValue: correctIdx, onChanged: (v) => setDialogState(() => correctIdx = v!)),
                    Expanded(child: TextField(controller: oCs[i], decoration: InputDecoration(labelText: "Option ${i + 1}"))),
                  ],
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
            ElevatedButton(
              onPressed: () {
                final newQ = QuizQuestion(
                  question: qC.text,
                  options: oCs.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
                  correctIndex: correctIdx,
                );
                setState(() {
                  if (index != null) _quizQuestions[index] = newQ;
                  else _quizQuestions.add(newQ);
                });
                Navigator.pop(context);
              },
              child: const Text("SAVE"),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiToolMenu extends StatelessWidget {
  final VoidCallback onResearch, onQuiz;
  final bool loading;
  const _AiToolMenu({required this.onResearch, required this.onQuiz, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
    return PopupMenuButton<int>(
      icon: const Icon(Icons.auto_awesome, color: AppColors.cranberry),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 1, child: ListTile(leading: Icon(Icons.search), title: Text("AI Research"))),
        const PopupMenuItem(value: 2, child: ListTile(leading: Icon(Icons.psychology), title: Text("AI Generate Quiz"))),
      ],
      onSelected: (val) => val == 1 ? onResearch() : onQuiz(),
    );
  }
}
