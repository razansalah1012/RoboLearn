import 'package:cloud_firestore/cloud_firestore.dart';

class RoleModel {
  final String id;
  final String roleName;
  final String roleTitle;
  final List<String> permissions;
  final String description;
  final DateTime createdAt;
  final String createdBy;
  final int userCount;

  RoleModel({
    required this.id,
    required this.roleName,
    required this.roleTitle,
    required this.permissions,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    this.userCount = 0,
  });

  Map<String, dynamic> toMap() => {
    'roleName': roleName,
    'roleTitle': roleTitle,
    'permissions': permissions,
    'description': description,
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
    'userCount': userCount,
  };

  factory RoleModel.fromMap(String id, Map<String, dynamic> map) => RoleModel(
    id: id,
    roleName: map['roleName'] ?? '',
    roleTitle: map['roleTitle'] ?? '',
    permissions: List<String>.from(map['permissions'] ?? []),
    description: map['description'] ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    createdBy: map['createdBy'] ?? '',
    userCount: (map['userCount'] as num? ?? 0).toInt(),
  );
}
