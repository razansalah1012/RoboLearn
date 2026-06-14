import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentBooking {
  final String id;
  final String equipmentId;
  final String equipmentName;
  final String equipmentImageUrl;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final int quantity;
  final DateTime bookingDate;
  final DateTime returnDate;
  final DateTime requestedAt;
  final String status; // Pending, Approved, Rejected, Returned
  final String notes;

  EquipmentBooking({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.equipmentImageUrl,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.quantity,
    required this.bookingDate,
    required this.returnDate,
    required this.requestedAt,
    required this.status,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'equipmentImageUrl': equipmentImageUrl,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'quantity': quantity,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'requestedAt': Timestamp.fromDate(requestedAt),
      'status': status,
      'notes': notes,
    };
  }

  factory EquipmentBooking.fromMap(String id, Map<String, dynamic> map) {
    return EquipmentBooking(
      id: id,
      equipmentId: map['equipmentId'] ?? '',
      equipmentName: map['equipmentName'] ?? '',
      equipmentImageUrl: map['equipmentImageUrl'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      bookingDate: (map['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnDate: (map['returnDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requestedAt: (map['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'Pending',
      notes: map['notes'] ?? '',
    );
  }

  EquipmentBooking copyWith({String? status}) {
    return EquipmentBooking(
      id: id,
      equipmentId: equipmentId,
      equipmentName: equipmentName,
      equipmentImageUrl: equipmentImageUrl,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      quantity: quantity,
      bookingDate: bookingDate,
      returnDate: returnDate,
      requestedAt: requestedAt,
      status: status ?? this.status,
      notes: notes,
    );
  }
}
