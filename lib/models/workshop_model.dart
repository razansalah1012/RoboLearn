import 'package:cloud_firestore/cloud_firestore.dart';

class Workshop {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String category; // Robotics, Drones, etc.
  final int capacity;
  final List<String> registeredUserIds;
  final String? imageUrl;

  Workshop({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.capacity,
    this.registeredUserIds = const [],
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'category': category,
      'capacity': capacity,
      'registeredUserIds': registeredUserIds,
      'imageUrl': imageUrl,
    };
  }

  factory Workshop.fromMap(String id, Map<String, dynamic> map) {
    return Workshop(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: map['location'] ?? '',
      category: map['category'] ?? '',
      capacity: map['capacity'] ?? 0,
      registeredUserIds: List<String>.from(map['registeredUserIds'] ?? []),
      imageUrl: map['imageUrl'],
    );
  }
}
