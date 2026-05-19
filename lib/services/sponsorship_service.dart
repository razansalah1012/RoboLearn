import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sponsorship_model.dart';

class SponsorshipService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Sponsorship>> getSponsorshipsStream() {
    return _db
        .collection('sponsorships')
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sponsorship.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> saveSponsorship(Sponsorship sponsorship) async {
    final data = sponsorship.toMap();
    if (sponsorship.id.isEmpty) {
      await _db.collection('sponsorships').add(data);
    } else {
      await _db.collection('sponsorships').doc(sponsorship.id).update(data);
    }
  }

  Future<void> deleteSponsorship(String id) async {
    await _db.collection('sponsorships').doc(id).delete();
  }
}
