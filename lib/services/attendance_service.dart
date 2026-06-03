import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_record_model.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<AttendanceRecord>> getAttendanceStream(String workshopId) {
    return _db
        .collection('attendance')
        .where('workshopId', isEqualTo: workshopId)
        .orderBy('checkedInAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceRecord.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<Map<String, dynamic>?> getAttendanceForUser(
    String workshopId,
    String userId,
  ) async {
    final snapshot = await _db
        .collection('attendance')
        .where('workshopId', isEqualTo: workshopId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return {'docId': doc.id, ...doc.data()};
  }

  Future<void> markCheckedIn({
    required String workshopId,
    required String workshopTitle,
    required String userId,
    required String userName,
    String? email,
  }) async {
    final existing = await getAttendanceForUser(workshopId, userId);

    if (existing != null) {
      await _db
          .collection('attendance')
          .doc(existing['docId']?.toString())
          .update({'checkedInAt': Timestamp.now(), 'status': 'Pending Verification'});
      return;
    }

    await _db.collection('attendance').add({
      'workshopId': workshopId,
      'workshopTitle': workshopTitle,
      'userId': userId,
      'userName': userName,
      'email': email,
      'checkedInAt': Timestamp.now(),
      'status': 'Pending Verification',
    });
  }

  Future<void> verifyAttendance(String attendanceId) async {
    await _db.collection('attendance').doc(attendanceId).update({
      'status': 'Verified',
    });
  }

  Future<void> rejectAttendance(String attendanceId) async {
    await _db.collection('attendance').doc(attendanceId).update({
      'status': 'Rejected',
    });
  }
}
