import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/learning_module_model.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';
import '../../services/certificate_service.dart';
import '../../theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  final LearningModule module;

  const QuizScreen({super.key, required this.module});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final CourseService _courseService = CourseService();
  final AuthService _authService = AuthService();
  final CertificateService _certificateService = CertificateService();
  
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  void _submitAnswer() {
    if (_selectedOptionIndex == null) return;
    setState(() {
      _isAnswered = true;
      if (_selectedOptionIndex == widget.module.quiz[_currentQuestionIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.module.quiz.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final userData = await _authService.getUserData(user.uid);
    final userName = userData?.name ?? "Learner";

    double percentage = (_score / widget.module.quiz.length) * 100;
    bool passed = percentage >= 70;

    if (passed) {
      // Determine if this is the last module in the course
      final allModules = await _courseService.getModules(widget.module.courseId);
      final isLastModule = allModules.isNotEmpty && allModules.last.id == widget.module.id;

      // PRO: Single atomic call for XP, Completion State, and Rankings
      await _courseService.completeModule(
        userId: user.uid,
        courseId: widget.module.courseId,
        moduleId: widget.module.id,
        score: _score,
        xpReward: widget.module.xpValue,
        isLastModule: isLastModule,
      );

      if (isLastModule) {
        await _certificateService.issueCertificate(
          userId: user.uid,
          userName: userName,
          courseId: widget.module.courseId,
          courseTitle: "Mastery of ${widget.module.courseId}",
        );
      }
    }

    if (!mounted) return;
    _showResultDialog(passed);
  }

  void _showResultDialog(bool passed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.ivory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(passed ? "Phase Mastery Achieved" : "Retake Required", 
          style: GoogleFonts.orbitron(color: passed ? Colors.green : AppColors.cranberry, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (passed) Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.bolt, color: Colors.orange, size: 40),
            ),
            const SizedBox(height: 16),
            Text("Score: $_score / ${widget.module.quiz.length}", style: GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(passed 
              ? "Your XP has been updated. The next milestone in the architecture is now accessible." 
              : "Minimum mastery of 70% is required to proceed with this technical path.",
              textAlign: TextAlign.center,
              style: GoogleFonts.exo2(color: AppColors.taupe),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cranberry),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to Path
            },
            child: const Text("CONTINUE PATH"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.module.quiz.isEmpty) return const Scaffold(body: Center(child: Text("Technical Assessment Data Missing")));
    final question = widget.module.quiz[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text("Module Assessment", style: GoogleFonts.orbitron(fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cranberry,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.module.quiz.length,
            backgroundColor: AppColors.ivory,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cranberry),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "VALIDATION POINT ${_currentQuestionIndex + 1}",
                    style: GoogleFonts.orbitron(fontSize: 12, color: AppColors.plum, letterSpacing: 2, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.question,
                    style: GoogleFonts.exo2(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
                  ),
                  const SizedBox(height: 40),
                  ...List.generate(question.options.length, (index) => _buildOption(index, question.options[index])),
                  
                  if (_isAnswered && question.explanation != null) ...[
                    const SizedBox(height: 24),
                    _ExplanationCard(text: question.explanation!),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.ivory, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.cranberry, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _selectedOptionIndex == null ? null : (_isAnswered ? _nextQuestion : _submitAnswer),
                child: Text(_isAnswered ? "CONTINUE" : "VALIDATE SELECTION", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int index, String text) {
    bool isCorrect = _isAnswered && index == widget.module.quiz[_currentQuestionIndex].correctIndex;
    bool isWrong = _isAnswered && _selectedOptionIndex == index && !isCorrect;

    return GestureDetector(
      onTap: _isAnswered ? null : () => setState(() => _selectedOptionIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green.withOpacity(0.1) : (isWrong ? Colors.red.withOpacity(0.1) : Colors.white),
          border: Border.all(
            width: 2,
            color: isCorrect ? Colors.green : (isWrong ? Colors.red : (_selectedOptionIndex == index ? AppColors.cranberry : AppColors.plum.withOpacity(0.1))),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: GoogleFonts.exo2(fontSize: 16, fontWeight: FontWeight.w500))),
            if (isCorrect) const Icon(Icons.check_circle, color: Colors.green)
            else if (isWrong) const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final String text;
  const _ExplanationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.plum.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.plum.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.plum),
              const SizedBox(width: 8),
              Text("ARCHITECT'S NOTE", style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.plum)),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: GoogleFonts.exo2(fontSize: 13, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }
}
