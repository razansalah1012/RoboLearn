import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/certificate_model.dart';

class CertificateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> issueCertificate({
    required String userId,
    required String userName,
    required String courseId,
    required String courseTitle,
  }) async {
    final docId = '${userId}_$courseId';
    final cert = Certificate(
      id: docId,
      userId: userId,
      userName: userName,
      courseId: courseId,
      courseTitle: courseTitle,
      issuedAt: DateTime.now(),
    );

    await _db.collection('certificates').doc(docId).set(cert.toMap());
  }

  Stream<List<Certificate>> getUserCertificates(String userId) {
    return _db
        .collection('certificates')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Certificate.fromMap(doc.id, doc.data()))
            .toList());
  }
}
