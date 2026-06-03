import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String workshopId;
  final String workshopTitle;
  final String userId;
  final String userName;
  final String? email;
  final DateTime checkedInAt;
  final String status;

  const AttendanceRecord({
    required this.id,
    required this.workshopId,
    required this.workshopTitle,
    required this.userId,
    required this.userName,
    this.email,
    required this.checkedInAt,
    this.status = 'Pending Verification',
  });

  Map<String, dynamic> toMap() => {
    'workshopId': workshopId,
    'workshopTitle': workshopTitle,
    'userId': userId,
    'userName': userName,
    'email': email,
    'checkedInAt': Timestamp.fromDate(checkedInAt),
    'status': status,
  };

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecord(
      id: id,
      workshopId: map['workshopId'] ?? '',
      workshopTitle: map['workshopTitle'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown member',
      email: map['email'],
      checkedInAt:
          (map['checkedInAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'Pending Verification',
    );
  }
}
