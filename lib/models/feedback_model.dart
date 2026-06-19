class FeedbackModel {
  final String id;
  final String workshopId;
  final String workshopName;
  final String userId;
  final String userName;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.workshopId,
    required this.workshopName,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workshopId': workshopId,
      'workshopName': workshopName,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedbackModel(
      id: id,
      workshopId: map['workshopId'] ?? '',
      workshopName: map['workshopName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }
}