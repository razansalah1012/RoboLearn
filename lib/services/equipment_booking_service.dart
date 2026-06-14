import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipment_booking_model.dart';

class EquipmentBookingService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('equipment_bookings');

  Stream<List<EquipmentBooking>> getUserBookingsStream(String userId) {
    return _collection
        .where('studentId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => EquipmentBooking.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
          return list;
        });
  }

  Stream<List<EquipmentBooking>> getAllBookingsStream() {
    return _collection
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => EquipmentBooking.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> createBooking(EquipmentBooking booking) async {
    await _collection.add(booking.toMap());
  }

  Future<void> updateStatus(EquipmentBooking booking, String newStatus) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    batch.update(_collection.doc(booking.id), {'status': newStatus});

    final equipmentRef = db.collection('equipment').doc(booking.equipmentId);
    if (newStatus == 'Approved') {
      // Item is taken out — decrease quantity
      batch.update(equipmentRef, {'quantity': FieldValue.increment(-booking.quantity)});
    } else if (newStatus == 'Returned') {
      // Item is back in lab — restore quantity
      batch.update(equipmentRef, {'quantity': FieldValue.increment(booking.quantity)});
    }

    await batch.commit();
  }

  Future<void> cancelBooking(String bookingId) async {
    await _collection.doc(bookingId).delete();
  }
}
