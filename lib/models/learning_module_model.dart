import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
    );
  }
}

class LearningModule {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category;
  final String difficulty; // 'Beginner' | 'Intermediate' | 'Advanced'
  final String createdBy;
  final DateTime createdAt;
  final List<QuizQuestion> quiz;

  LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.difficulty,
    required this.createdBy,
    required this.createdAt,
    this.quiz = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'difficulty': difficulty,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'quiz': quiz.map((q) => q.toMap()).toList(),
    };
  }

  factory LearningModule.fromMap(String id, Map<String, dynamic> map) {
    return LearningModule(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'General',
      difficulty: map['difficulty'] ?? 'Beginner',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      quiz: (map['quiz'] as List? ?? [])
          .map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q)))
          .toList(),
    );
  }
}
