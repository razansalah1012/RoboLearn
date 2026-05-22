import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workshop_model.dart';

class WorkshopService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Student Logic ---

  Stream<List<Workshop>> getUpcomingWorkshops() {
    // Fetching all and filtering client-side is safer during development
    // to avoid missing field or index issues in Firestore.
    return _db
        .collection('workshops')
        .snapshots()
        .map((snapshot) {
          final workshops = snapshot.docs
            .map((doc) => Workshop.fromMap(doc.id, doc.data()))
            .where((w) => !w.isCompleted) // Only show active/upcoming
            .toList();
          
          // Sort by date ascending (soonest first)
          workshops.sort((a, b) => a.date.compareTo(b.date));
          return workshops;
        });
  }

  Stream<List<Workshop>> getUserWorkshops(String userId) {
    return _db
        .collection('workshops')
        .where('registeredUserIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workshop.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> registerForWorkshop(String userId, String workshopId) async {
    await _db.collection('workshops').doc(workshopId).update({
      'registeredUserIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> cancelRegistration(String userId, String workshopId) async {
    await _db.collection('workshops').doc(workshopId).update({
      'registeredUserIds': FieldValue.arrayRemove([userId]),
    });
  }

  // --- Admin/Committee Logic ---

  Future<void> saveWorkshop(Workshop workshop) async {
    final data = workshop.toMap();
    if (workshop.id.isEmpty) {
      await _db.collection('workshops').add(data);
    } else {
      await _db.collection('workshops').doc(workshop.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteWorkshop(String workshopId) async {
    await _db.collection('workshops').doc(workshopId).delete();
  }

  Stream<List<Workshop>> getAllWorkshopsStream() {
    return _db.collection('workshops')
        .snapshots()
        .map((snapshot) {
          final workshops = snapshot.docs
            .map((doc) => Workshop.fromMap(doc.id, doc.data()))
            .toList();
          workshops.sort((a, b) => b.date.compareTo(a.date));
          return workshops;
        });
  }

  Future<void> markAsCompleted(String workshopId, bool completed) async {
    await _db.collection('workshops').doc(workshopId).update({
      'isCompleted': completed,
    });
  }

  Future<List<Map<String, dynamic>>> getParticipants(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    List<Map<String, dynamic>> participants = [];
    for (int i = 0; i < userIds.length; i += 30) {
      final chunk = userIds.sublist(i, i + 30 > userIds.length ? userIds.length : i + 30);
      final snap = await _db.collection('users').where(FieldPath.documentId, whereIn: chunk).get();
      participants.addAll(snap.docs.map((d) => {'id': d.id, ...d.data()}));
    }
    return participants;
  }
}
