import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workshop_model.dart';

class WorkshopService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Student Logic ---

  Stream<List<Workshop>> getUpcomingWorkshops() {
    return _db
        .collection('workshops')
        .where('date', isGreaterThan: Timestamp.now())
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workshop.fromMap(doc.id, doc.data() as Map<String, dynamic>))
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

  // --- Admin/Committee Logic (Pro Architect Tools) ---

  Future<void> saveWorkshop(Workshop workshop) async {
    final data = workshop.toMap();
    if (workshop.id.isEmpty) {
      await _db.collection('workshops').add(data);
    } else {
      await _db.collection('workshops').doc(workshop.id).update(data);
    }
  }

  Future<void> deleteWorkshop(String workshopId) async {
    await _db.collection('workshops').doc(workshopId).delete();
  }

  Stream<List<Workshop>> getAllWorkshopsStream() {
    return _db.collection('workshops').orderBy('date', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Workshop.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}
