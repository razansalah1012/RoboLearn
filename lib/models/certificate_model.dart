import 'package:cloud_firestore/cloud_firestore.dart';

class Certificate {
  final String id;
  final String userId;
  final String userName;
  final String courseId;
  final String courseTitle;
  final DateTime issuedAt;

  Certificate({
    required this.id,
    required this.userId,
    required this.userName,
    required this.courseId,
    required this.courseTitle,
    required this.issuedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'issuedAt': Timestamp.fromDate(issuedAt),
    };
  }

  factory Certificate.fromMap(String id, Map<String, dynamic> map) {
    return Certificate(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      courseId: map['courseId'] ?? '',
      courseTitle: map['courseTitle'] ?? '',
      issuedAt: (map['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
