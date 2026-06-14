import 'package:cloud_firestore/cloud_firestore.dart';

class Sponsorship {
  final String id;
  final String companyName;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final double amount;
  final String purpose;
  final String workshopId;
  final String status; // Pending, Approved, Rejected, Received
  final String notes;
  final DateTime appliedDate;
  final DateTime lastUpdated;
  final String createdBy;

  Sponsorship({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
    required this.amount,
    required this.purpose,
    this.workshopId = '',
    required this.status,
    required this.notes,
    required this.appliedDate,
    required this.lastUpdated,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'amount': amount,
      'purpose': purpose,
      'workshopId': workshopId,
      'status': status,
      'notes': notes,
      'appliedDate': Timestamp.fromDate(appliedDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'createdBy': createdBy,
    };
  }

  factory Sponsorship.fromMap(String id, Map<String, dynamic> map) {
    return Sponsorship(
      id: id,
      companyName: map['companyName'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      purpose: map['purpose'] ?? '',
      workshopId: map['workshopId'] ?? '',
      status: map['status'] ?? 'Pending',
      notes: map['notes'] ?? '',
      appliedDate: (map['appliedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }
}
