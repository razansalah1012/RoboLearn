import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/learning_module_model.dart';
import '../models/user_progress_model.dart';

class CourseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Course Architect (Club Member) CRUD ---

  Future<String> saveCourse(Course course) async {
    final data = course.toMap();
    if (course.id.isEmpty) {
      final doc = await _db.collection('courses').add(data);
      return doc.id;
    } else {
      await _db.collection('courses').doc(course.id).update(data);
      return course.id;
    }
  }

  Future<void> saveModule(LearningModule module) async {
    final data = module.toMap();
    if (module.id.isEmpty) {
      await _db.collection('modules').add(data);
    } else {
      await _db.collection('modules').doc(module.id).update(data);
    }
  }

  Future<void> togglePublishCourse(String courseId, bool status) async {
    await _db.collection('courses').doc(courseId).update({
      'isPublished': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Content Retrieval ---

  Future<List<Course>> getCoursesByCategory(String category) async {
    QuerySnapshot snapshot = await _db
        .collection('courses')
        .where('category', isEqualTo: category)
        .where('isPublished', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Course.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<Course>> getAllCoursesStream() {
    return _db.collection('courses')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Course.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Future<List<LearningModule>> getModules(String courseId) async {
    QuerySnapshot snapshot = await _db
        .collection('modules')
        .where('courseId', isEqualTo: courseId)
        .get();
    
    final modules = snapshot.docs
        .map((doc) => LearningModule.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    modules.sort((a, b) => a.order.compareTo(b.order));
    return modules;
  }

  Stream<List<LearningModule>> getModulesStream(String courseId) {
    return _db.collection('modules')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
          final modules = snapshot.docs
              .map((doc) => LearningModule.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          modules.sort((a, b) => a.order.compareTo(b.order));
          return modules;
        });
  }

  // --- User Progress ---

  Stream<UserProgress?> getUserProgress(String userId, String courseId) {
    return _db
        .collection('user_progress')
        .doc('${userId}_$courseId')
        .snapshots()
        .map((doc) => doc.exists ? UserProgress.fromMap(doc.data()!) : null);
  }

  Future<void> markLessonAsCompleted(String userId, String courseId, String lessonId) async {
    final docRef = _db.collection('user_progress').doc('${userId}_$courseId');
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'userId': userId,
          'courseId': courseId,
          'completedLessonIds': [lessonId],
          'completedModuleIds': [],
          'quizScores': {},
          'totalXp': 0,
          'isCourseCompleted': false,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(docRef, {
          'completedLessonIds': FieldValue.arrayUnion([lessonId]),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  bool isModuleUnlocked(LearningModule module, List<LearningModule> allModules, UserProgress? progress) {
    if (module.order == 0) return true;
    try {
      final previousModule = allModules.firstWhere((m) => m.order == module.order - 1);
      return progress?.completedModuleIds.contains(previousModule.id) ?? false;
    } catch (e) {
      return false;
    }
  }

  bool isLessonUnlocked(Lesson lesson, LearningModule module, UserProgress? progress) {
    if (lesson.order == 0) return true;
    try {
      final previousLesson = module.lessons.firstWhere((l) => l.order == lesson.order - 1);
      return progress?.completedLessonIds.contains(previousLesson.id) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> completeModule({
    required String userId,
    required String courseId,
    required String moduleId,
    required int score,
    required int xpReward,
    required bool isLastModule,
  }) async {
    final progressRef = _db.collection('user_progress').doc('${userId}_$courseId');
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(progressRef);
      
      if (!snapshot.exists) {
        final newProgress = UserProgress(
          userId: userId,
          courseId: courseId,
          completedModuleIds: [moduleId],
          quizScores: {moduleId: score},
          totalXp: xpReward,
          isCourseCompleted: isLastModule,
        );
        transaction.set(progressRef, newProgress.toMap());
      } else {
        final data = snapshot.data()!;
        List<String> completedModules = List<String>.from(data['completedModuleIds'] ?? []);
        Map<String, dynamic> scores = Map<String, dynamic>.from(data['quizScores'] ?? {});
        int currentXp = (data['totalXp'] as num? ?? 0).toInt();

        if (!completedModules.contains(moduleId)) {
          completedModules.add(moduleId);
          scores[moduleId] = score;
          currentXp += xpReward;
        }

        transaction.update(progressRef, {
          'completedModuleIds': completedModules,
          'quizScores': scores,
          'totalXp': currentXp,
          'isCourseCompleted': isLastModule,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      final userRef = _db.collection('users').doc(userId);
      final userSnap = await transaction.get(userRef);
      if (userSnap.exists) {
        int userXp = (userSnap.data()?['totalXp'] as num? ?? 0).toInt();
        transaction.update(userRef, {'totalXp': userXp + xpReward});
      }
    });
  }

  // --- Active Courses & Dashboard ---

  Stream<List<Map<String, dynamic>>> getActiveUserCourses(String userId) {
    return _db.collection('user_progress')
        .where('userId', isEqualTo: userId)
        .where('isCourseCompleted', isEqualTo: false)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> activePaths = [];
          for (var doc in snapshot.docs) {
            final progress = UserProgress.fromMap(doc.data());
            final courseDoc = await _db.collection('courses').doc(progress.courseId).get();
            if (courseDoc.exists) {
              final course = Course.fromMap(courseDoc.id, courseDoc.data()!);
              activePaths.add({
                'course': course,
                'progress': progress,
              });
            }
          }
          return activePaths;
        });
  }

  Future<int> getModulesCount(String courseId) async {
    final snap = await _db.collection('modules').where('courseId', isEqualTo: courseId).get();
    return snap.docs.length;
  }
}
