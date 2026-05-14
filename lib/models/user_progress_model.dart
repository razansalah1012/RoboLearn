import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String userId;
  final String courseId;
  final List<String> completedModuleIds;
  final List<String> completedLessonIds;
  final Map<String, int> quizScores; 
  final int totalXp;
  final bool isCourseCompleted;

  UserProgress({
    required this.userId,
    required this.courseId,
    this.completedModuleIds = const [],
    this.completedLessonIds = const [],
    this.quizScores = const {},
    this.totalXp = 0,
    this.isCourseCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courseId': courseId,
      'completedModuleIds': completedModuleIds,
      'completedLessonIds': completedLessonIds,
      'quizScores': quizScores,
      'totalXp': totalXp,
      'isCourseCompleted': isCourseCompleted,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] ?? '',
      courseId: map['courseId'] ?? '',
      completedModuleIds: List<String>.from(map['completedModuleIds'] ?? []),
      completedLessonIds: List<String>.from(map['completedLessonIds'] ?? []),
      quizScores: Map<String, int>.from(map['quizScores'] ?? {}),
      totalXp: map['totalXp'] ?? 0,
      isCourseCompleted: map['isCourseCompleted'] ?? false,
    );
  }
}
