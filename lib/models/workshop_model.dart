import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkshopDifficulty { beginner, intermediate, advanced }

class Workshop {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String category; 
  final int capacity;
  final WorkshopDifficulty difficulty;
  final String? imageUrl;
  final String prerequisites;
  final DateTime registrationDeadline;
  final List<String> registeredUserIds;
  final bool isCompleted;
  final String objectives;
  final String instructorName;

  Workshop({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.capacity,
    required this.difficulty,
    this.imageUrl,
    this.prerequisites = '',
    required this.registrationDeadline,
    this.registeredUserIds = const [],
    this.isCompleted = false,
    this.objectives = '',
    this.instructorName = '',
  });

  int get availableSlots => capacity - registeredUserIds.length;
  bool get isFull => registeredUserIds.length >= capacity;
  bool get isRegistrationOpen => 
    !isCompleted && 
    DateTime.now().isBefore(registrationDeadline) && 
    !isFull;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'category': category,
      'capacity': capacity,
      'difficulty': difficulty.name,
      'imageUrl': imageUrl,
      'prerequisites': prerequisites,
      'registrationDeadline': Timestamp.fromDate(registrationDeadline),
      'registeredUserIds': registeredUserIds,
      'isCompleted': isCompleted,
      'objectives': objectives,
      'instructorName': instructorName,
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
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      difficulty: WorkshopDifficulty.values.firstWhere(
        (e) => e.name == (map['difficulty'] ?? 'beginner'),
        orElse: () => WorkshopDifficulty.beginner,
      ),
      imageUrl: map['imageUrl'],
      prerequisites: map['prerequisites'] ?? '',
      registrationDeadline: (map['registrationDeadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      registeredUserIds: List<String>.from(map['registeredUserIds'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      objectives: map['objectives'] ?? '',
      instructorName: map['instructorName'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Workshop) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
