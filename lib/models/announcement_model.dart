import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String content;
  final String type;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final String priority;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.priority = 'normal',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Timestamp
      'priority': priority,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map, String id) {
    // Handle both Timestamp and DateTime
    DateTime createdAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is DateTime) {
      createdAt = map['createdAt'] as DateTime;
    } else {
      createdAt = DateTime.now();
    }

    return Announcement(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'announcement',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: createdAt,
      priority: map['priority'] ?? 'normal',
    );
  }
}