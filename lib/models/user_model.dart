import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student', 'committee', 'admin'
  final String? roleTitle; // e.g., 'Vice-President', 'Technical Lead'
  final String? profilePhotoUrl;
  final DateTime joinDate;
  final bool isActive;
  final bool isBlocked;
  final bool notificationsEnabled;
  final String? matricNumber;
  final String? phoneNumber;
  final bool isApproved;
  final int totalXp;
  final int completedCoursesCount;
  
  // Committee specific stats
  final int coursesManaged;
  final int eventsParticipated;
  final int xpIssued;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.roleTitle,
    this.profilePhotoUrl,
    required this.joinDate,
    this.isActive = true,
    this.isBlocked = false,
    this.notificationsEnabled = true,
    this.matricNumber,
    this.phoneNumber,
    this.isApproved = true,
    this.totalXp = 0,
    this.completedCoursesCount = 0,
    this.coursesManaged = 0,
    this.eventsParticipated = 0,
    this.xpIssued = 0,
  });

  /// Logic: Every 500 XP is a level
  int get level => (totalXp / 500).floor() + 1;

  /// Progress to next level (0.0 to 1.0)
  double get levelProgress => (totalXp % 500) / 500;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'roleTitle': roleTitle,
      'profilePhotoUrl': profilePhotoUrl,
      'joinDate': Timestamp.fromDate(joinDate),
      'isActive': isActive,
      'isBlocked': isBlocked,
      'notificationsEnabled': notificationsEnabled,
      'matricNumber': matricNumber,
      'phoneNumber': phoneNumber,
      'isApproved': isApproved,
      'totalXp': totalXp,
      'completedCoursesCount': completedCoursesCount,
      'coursesManaged': coursesManaged,
      'eventsParticipated': eventsParticipated,
      'xpIssued': xpIssued,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      roleTitle: map['roleTitle'],
      profilePhotoUrl: map['profilePhotoUrl'],
      joinDate: (map['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      isBlocked: map['isBlocked'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      matricNumber: map['matricNumber'],
      phoneNumber: map['phoneNumber'],
      isApproved: map['isApproved'] ?? true,
      totalXp: (map['totalXp'] as num? ?? 0).toInt(),
      completedCoursesCount: (map['completedCoursesCount'] as num? ?? 0).toInt(),
      coursesManaged: (map['coursesManaged'] as num? ?? 0).toInt(),
      eventsParticipated: (map['eventsParticipated'] as num? ?? 0).toInt(),
      xpIssued: (map['xpIssued'] as num? ?? 0).toInt(),
    );
  }

  UserModel copyWith({
    String? name,
    String? role,
    String? roleTitle,
    String? profilePhotoUrl,
    bool? isActive,
    bool? isBlocked,
    bool? notificationsEnabled,
    String? matricNumber,
    String? phoneNumber,
    bool? isApproved,
    int? totalXp,
    int? completedCoursesCount,
    int? coursesManaged,
    int? eventsParticipated,
    int? xpIssued,
  }) {
    return UserModel(
      uid: this.uid,
      email: this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      roleTitle: roleTitle ?? this.roleTitle,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      joinDate: this.joinDate,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      matricNumber: matricNumber ?? this.matricNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isApproved: isApproved ?? this.isApproved,
      totalXp: totalXp ?? this.totalXp,
      completedCoursesCount: completedCoursesCount ?? this.completedCoursesCount,
      coursesManaged: coursesManaged ?? this.coursesManaged,
      eventsParticipated: eventsParticipated ?? this.eventsParticipated,
      xpIssued: xpIssued ?? this.xpIssued,
    );
  }
}
