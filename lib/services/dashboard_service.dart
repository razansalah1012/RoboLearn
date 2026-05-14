import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream for Committee Overview Stats
  Stream<Map<String, dynamic>> getCommitteeStats() {
    return _db.collection('users').snapshots().map((snapshot) {
      int activeStudents = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['role'] == 'student' && data['isActive'] == true;
      }).length;

      // We use totalXp as the aggregate XP issued by the system
      int totalXpIssued = snapshot.docs
          .where((doc) => doc.data()['role'] == 'student')
          .fold(0, (sum, doc) => sum + ((doc.data()['totalXp'] as num?)?.toInt() ?? 0));

      return {
        'activeStudents': activeStudents,
        'totalXpIssued': totalXpIssued,
      };
    });
  }

  Stream<int> getTotalCoursesCount() {
    return _db.collection('courses').snapshots().map((snap) => snap.docs.length);
  }

  // Admin Stats
  Stream<Map<String, dynamic>> getAdminStats() {
    return _db.collection('users').snapshots().map((snapshot) {
      int admins = snapshot.docs.where((doc) => doc.data()['role'] == 'admin').length;
      int committee = snapshot.docs.where((doc) => doc.data()['role'] == 'committee').length;
      int students = snapshot.docs.where((doc) => doc.data()['role'] == 'student').length;
      
      // Committee members are the ones requiring admin approval
      int pendingApprovals = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['role'] == 'committee' && data['isApproved'] == false;
      }).length;

      return {
        'admins': admins,
        'committee': committee,
        'students': students,
        'pendingApprovals': pendingApprovals,
      };
    });
  }

  Stream<List<Map<String, dynamic>>> getRecentActivity() {
    return _db.collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }
}
