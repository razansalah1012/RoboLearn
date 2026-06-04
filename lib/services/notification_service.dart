import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<NotificationItem>> getNotificationsStream() {
    return _db
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationItem.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> saveNotification(NotificationItem notification) async {
    final data = notification.toMap();
    if (notification.id.isEmpty) {
      await _db.collection('notifications').add(data);
    } else {
      await _db.collection('notifications').doc(notification.id).set(data, SetOptions(merge: true));
    }
  }
}
