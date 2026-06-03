class Announcement {
  final String id;
  final String title;
  final String content;
  final String type; // 'announcement', 'update', 'material'
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final String priority; // 'high', 'normal'

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
      'createdAt': createdAt,
      'priority': priority,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map, String id) {
    return Announcement(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'announcement',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.now(),
      priority: map['priority'] ?? 'normal',
    );
  }
}