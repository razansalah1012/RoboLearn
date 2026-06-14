import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipment_model.dart';

class EquipmentService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('equipment');

  Stream<List<Equipment>> getEquipmentStream() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Equipment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> saveEquipment(Equipment equipment) async {
    final data = equipment.toMap();
    if (equipment.id.isEmpty) {
      await _collection.add(data);
    } else {
      await _collection.doc(equipment.id).update(data);
    }
  }

  Future<void> deleteEquipment(String id) async {
    await _collection.doc(id).delete();
  }
}
