import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/learning_module_model.dart';
import '../../models/user_progress_model.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_service.dart';
import '../../theme/app_colors.dart';
import 'quiz_screen.dart';

class LessonViewScreen extends StatefulWidget {
  final LearningModule module;
  final int lessonIndex;
  final UserProgress? progress;

  const LessonViewScreen({
    super.key,
    required this.module,
    required this.lessonIndex,
    this.progress,
  });

  @override
  State<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends State<LessonViewScreen> {
  final CourseService _courseService = CourseService();
  final AuthService _authService = AuthService();
  final GeminiService _geminiService = GeminiService();

  Lesson get currentLesson => widget.module.lessons[widget.lessonIndex];
  bool get isLastLesson => widget.lessonIndex == widget.module.lessons.length - 1;

  bool _isAiExplaining = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(widget.module.title, style: GoogleFonts.orbitron(fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cranberry,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (widget.lessonIndex + 1) / widget.module.lessons.length,
            backgroundColor: AppColors.ivory.withAlpha(100),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cranberry),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentLesson.title,
                          style: GoogleFonts.orbitron(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cranberry,
                          ),
                        ),
                      ),
                      _AiMentorButton(
                        onPressed: _showAiExplanation,
                        isLoading: _isAiExplaining,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (currentLesson.videoUrl != null)
                    _VideoPlayerCard(url: currentLesson.videoUrl!),
                  const SizedBox(height: 24),
                  MarkdownBody(
                    data: currentLesson.content,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.exo2(fontSize: 16, height: 1.6, color: Colors.black87),
                      h1: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.plum),
                      code: GoogleFonts.firaMono(backgroundColor: AppColors.beige.withAlpha(150), color: AppColors.cranberry),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.black.withAlpha(5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (currentLesson.codeSnippet != null) ...[
                    const SizedBox(height: 24),
                    _CodeSnippetCard(code: currentLesson.codeSnippet!),
                  ],
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.ivory,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.lessonIndex > 0)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cranberry),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("PREVIOUS"),
              )
            else
              const SizedBox.shrink(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cranberry,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              onPressed: _onNext,
              child: Text(
                isLastLesson ? "TAKE ASSESSMENT" : "NEXT LESSON",
                style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onNext() async {
    final user = _authService.currentUser;
    if (user != null) {
      await _courseService.markLessonAsCompleted(
        user.uid,
        widget.module.courseId,
        currentLesson.id,
      );
    }

    if (!mounted) return;

    if (isLastLesson) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(module: widget.module),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LessonViewScreen(
            module: widget.module,
            lessonIndex: widget.lessonIndex + 1,
            progress: widget.progress,
          ),
        ),
      );
    }
  }

  Future<void> _showAiExplanation() async {
    setState(() => _isAiExplaining = true);
    
    // In a real pro app, we'd send the content to Gemini API
    // Here we use our GeminiService to get research/explanation
    final explanation = await _geminiService.researchCategory(widget.module.title);
    
    if (!mounted) return;
    setState(() => _isAiExplaining = false);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ivory,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.cranberry),
                const SizedBox(width: 12),
                Text("AI Technical Mentor", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Text(explanation['title'] ?? 'Technical Insights', style: GoogleFonts.exo2(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(explanation['content'] ?? 'Deep learning insight unavailable at this moment.', style: GoogleFonts.exo2(height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("GOT IT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiMentorButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  const _AiMentorButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading 
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cranberry))
        : const Icon(Icons.auto_awesome_outlined, color: AppColors.cranberry),
      tooltip: "Explain with AI",
    );
  }
}

class _VideoPlayerCard extends StatelessWidget {
  final String url;
  const _VideoPlayerCard({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cranberry.withAlpha(50), blurRadius: 15)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
          Positioned(
            bottom: 12,
            left: 12,
            child: Text(
              "Instructional Video Available",
              style: GoogleFonts.exo2(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeSnippetCard extends StatelessWidget {
  final String code;
  const _CodeSnippetCard({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cranberry.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 8),
              Text("TECHNICAL SNIPPET", style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white54, letterSpacing: 1)),
            ],
          ),
          const Divider(color: Colors.white12),
          Text(
            code,
            style: GoogleFonts.firaMono(
              color: const Color(0xFFCE9178),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
