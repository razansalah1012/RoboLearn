import 'package:cloud_firestore/cloud_firestore.dart';

enum Difficulty { beginner, intermediate, advanced }

class Lesson {
  final String id;
  final String title;
  final String content;
  final String? videoUrl;
  final String? codeSnippet;
  final int order;
  final int xpReward;
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    this.videoUrl,
    this.codeSnippet,
    required this.order,
    this.xpReward = 20,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'videoUrl': videoUrl,
    'codeSnippet': codeSnippet,
    'order': order,
    'xpReward': xpReward,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    videoUrl: map['videoUrl'],
    codeSnippet: map['codeSnippet'],
    order: (map['order'] as num? ?? 0).toInt(),
    xpReward: (map['xpReward'] as num? ?? 20).toInt(),
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final int xpReward;
  final String? explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.xpReward = 10,
    this.explanation,
  });

  Map<String, dynamic> toMap() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'xpReward': xpReward,
    'explanation': explanation,
  };

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
    question: map['question'] ?? '',
    options: List<String>.from(map['options'] ?? []),
    correctIndex: (map['correctIndex'] as num? ?? 0).toInt(),
    xpReward: (map['xpReward'] as num? ?? 10).toInt(),
    explanation: map['explanation'],
  );
}

class LearningModule {
  final String id;
  final String title;
  final String description;
  final int order;
  final String courseId;
  final int xpValue;
  final List<Lesson> lessons;
  final List<QuizQuestion> quiz;
  final DateTime createdAt;

  LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.courseId,
    this.xpValue = 100,
    this.lessons = const [],
    this.quiz = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'order': order,
    'courseId': courseId,
    'xpValue': xpValue,
    'lessons': lessons.map((l) => l.toMap()).toList(),
    'quiz': quiz.map((q) => q.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory LearningModule.fromMap(String id, Map<String, dynamic> map) => LearningModule(
    id: id,
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    order: (map['order'] as num? ?? 0).toInt(),
    courseId: map['courseId'] ?? '',
    xpValue: (map['xpValue'] as num? ?? 100).toInt(),
    lessons: (map['lessons'] as List? ?? [])
        .map((l) => Lesson.fromMap(Map<String, dynamic>.from(l)))
        .toList(),
    quiz: (map['quiz'] as List? ?? [])
        .map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q)))
        .toList(),
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final Difficulty difficulty;
  final String createdBy;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int totalEnrolled;
  final int totalLessons;
  final int totalXP;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.createdBy,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
    this.totalEnrolled = 0,
    this.totalLessons = 0,
    this.totalXP = 0,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'difficulty': difficulty.name,
    'createdBy': createdBy,
    'thumbnailUrl': thumbnailUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'isPublished': isPublished,
    'totalEnrolled': totalEnrolled,
    'totalLessons': totalLessons,
    'totalXP': totalXP,
  };

  factory Course.fromMap(String id, Map<String, dynamic> map) => Course(
    id: id,
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    category: map['category'] ?? '',
    difficulty: Difficulty.values.firstWhere(
      (e) => e.name == (map['difficulty'] ?? 'beginner'),
      orElse: () => Difficulty.beginner,
    ),
    createdBy: map['createdBy'] ?? '',
    thumbnailUrl: map['thumbnailUrl'],
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    isPublished: map.containsKey('isPublished') ? (map['isPublished'] ?? false) : true,
    totalEnrolled: (map['totalEnrolled'] as num? ?? 0).toInt(),
    totalLessons: (map['totalLessons'] as num? ?? 0).toInt(),
    totalXP: (map['totalXP'] as num? ?? 0).toInt(),
  );
}
