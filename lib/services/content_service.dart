import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'announcements';

  // Create new announcement (Committee/Admin only)
  Future<bool> createAnnouncement(Announcement announcement) async {
    try {
      await _firestore.collection(_collection).doc(announcement.id).set(announcement.toMap());
      return true;
    } catch (e) {
      print('Error creating announcement: $e');
      return false;
    }
  }

  // Get all announcements (for all users)
  Stream<List<Announcement>> getAllAnnouncements() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Announcement.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get only announcements (filtered by type)
  Stream<List<Announcement>> getAnnouncementsByType(String type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Announcement.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Delete announcement (Committee/Admin only)
  Future<bool> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting announcement: $e');
      return false;
    }
  }
}