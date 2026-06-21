import 'package:cloud_firestore/cloud_firestore.dart';

class Equipment {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int quantity;
  final String createdBy;
  final DateTime createdAt;
  final DateTime lastUpdated;

  Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.quantity,
    required this.createdBy,
    required this.createdAt,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory Equipment.fromMap(String id, Map<String, dynamic> map) {
    return Equipment(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
